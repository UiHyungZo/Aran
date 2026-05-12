import Foundation

protocol CycleRecordRepositoryProtocol {
    func fetchAll() async throws -> [CycleRecord]
    func fetch(date: Date) async throws -> CycleRecord?
    func save(_ record: CycleRecord) async throws
    func update(_ record: CycleRecord) async throws
    func delete(id: UUID) async throws
}
