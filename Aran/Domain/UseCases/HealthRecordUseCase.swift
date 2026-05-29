import Foundation

protocol HealthRecordUseCaseProtocol {
    func fetchAll() async throws -> [HealthRecord]
    func fetch(type: String) async throws -> [HealthRecord]
    func save(type: String, value: Double, unit: String, recordDate: Date, memo: String?) async throws
    func update(_ record: HealthRecord) async throws
    func fetchLatestPerItem() async throws -> [String: [HealthRecord]]
    func delete(id: UUID) async throws
}

final class HealthRecordUseCase: HealthRecordUseCaseProtocol {
    private let repository: HealthRecordRepositoryProtocol

    init(repository: HealthRecordRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [HealthRecord] {
        return try await repository.fetchAll()
    }

    func fetch(type: String) async throws -> [HealthRecord] {
        let records = try await repository.fetch(type: type)
        return records.sorted { $0.recordDate > $1.recordDate }
    }

    func save(type: String, value: Double, unit: String, recordDate: Date, memo: String?) async throws {
        let normalizedType = type.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedType.isEmpty else {
            throw AppError.invalidInput("검사 항목을 입력해주세요.")
        }
        guard !value.isNaN, !value.isInfinite else {
            throw AppError.invalidInput("유효하지 않은 수치입니다.")
        }
        guard value > 0 else {
            throw AppError.invalidInput("유효한 수치를 입력해주세요.")
        }
        guard value < 999_999 else {
            throw AppError.invalidInput("수치가 허용 범위를 초과했습니다.")
        }
        guard !normalizedUnit.isEmpty else {
            throw AppError.invalidInput("단위를 입력해주세요.")
        }
        let record = HealthRecord(
            id: UUID(),
            type: normalizedType,
            value: value,
            unit: normalizedUnit,
            recordDate: recordDate,
            memo: memo
        )
        try await repository.save(record)
    }

    func update(_ record: HealthRecord) async throws {
        guard !record.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidInput("검사 항목을 입력해주세요.")
        }
        guard !record.value.isNaN, !record.value.isInfinite else {
            throw AppError.invalidInput("유효하지 않은 수치입니다.")
        }
        guard record.value > 0 else {
            throw AppError.invalidInput("유효한 수치를 입력해주세요.")
        }
        guard record.value < 999_999 else {
            throw AppError.invalidInput("수치가 허용 범위를 초과했습니다.")
        }
        guard !record.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidInput("단위를 입력해주세요.")
        }
        try await repository.update(record)
    }

    func fetchLatestPerItem() async throws -> [String: [HealthRecord]] {
        let all = try await repository.fetchAll()
        var grouped: [String: [HealthRecord]] = [:]
        for record in all {
            grouped[record.type, default: []].append(record)
        }
        for key in grouped.keys {
            grouped[key] = grouped[key]?.sorted { $0.recordDate > $1.recordDate }
        }
        return grouped
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
