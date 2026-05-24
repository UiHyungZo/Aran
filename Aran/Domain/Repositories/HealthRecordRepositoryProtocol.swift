import Foundation

protocol HealthRecordRepositoryProtocol {
    func fetchAll() async throws -> [HealthRecord]
    func fetch(item: TestItem) async throws -> [HealthRecord]
    func save(_ record: HealthRecord) async throws
    func delete(id: UUID) async throws
}
