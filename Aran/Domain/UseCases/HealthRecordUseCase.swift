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
        let record = HealthRecord(id: UUID(), testItem: item, value: value, date: date, note: note)
        try await repository.save(record)
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
