import Foundation

final class HealthRecordUseCase {
    private let repository: HealthRecordRepositoryProtocol

    init(repository: HealthRecordRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [HealthRecord] {
        return try await repository.fetchAll()
    }

    func fetch(item: TestItem) async throws -> [HealthRecord] {
        let records = try await repository.fetch(item: item)
        return records.sorted { $0.date > $1.date }
    }

    func save(item: TestItem, value: Double, date: Date, note: String?) async throws {
        guard value > 0 else {
            throw AppError.invalidInput("유효한 수치를 입력해주세요.")
        }
        let record = HealthRecord(id: UUID(), testItem: item, value: value, date: date, note: note, pgtResult: nil)
        try await repository.save(record)
    }

    func savePGT(item: TestItem, result: PGTResult, date: Date, note: String?) async throws {
        guard !item.isNumeric else {
            throw AppError.invalidInput("PGT 항목만 저장할 수 있습니다.")
        }
        let total = result.normal + result.abnormal + result.mosaic
        guard total > 0 else {
            throw AppError.invalidInput("최소 1개 이상의 배아 결과를 입력해주세요.")
        }
        let record = HealthRecord(
            id: UUID(),
            testItem: item,
            value: Double(total),
            date: date,
            note: note,
            pgtResult: result
        )
        try await repository.save(record)
    }

    func fetchLatestPerItem() async throws -> [TestItem: [HealthRecord]] {
        let all = try await repository.fetchAll()
        var grouped: [TestItem: [HealthRecord]] = [:]
        for record in all {
            grouped[record.testItem, default: []].append(record)
        }
        for key in grouped.keys {
            grouped[key] = grouped[key]?.sorted { $0.date > $1.date }
        }
        return grouped
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
