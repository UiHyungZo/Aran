import Foundation

protocol PGTRecordRepositoryProtocol {
    func fetchAll() async throws -> [PGTRecord]
    func fetch(cycleRecordId: UUID) async throws -> [PGTRecord]
    func save(_ record: PGTRecord) async throws
    func delete(id: UUID) async throws
}
