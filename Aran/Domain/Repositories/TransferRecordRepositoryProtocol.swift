import Foundation

protocol TransferRecordRepositoryProtocol {
    func fetch(id: UUID) async throws -> TransferRecord?
    func fetch(for date: Date) async throws -> [TransferRecord]
    func fetchAll() async throws -> [TransferRecord]
    func save(_ record: TransferRecord) async throws
    func update(_ record: TransferRecord) async throws
    func delete(id: UUID) async throws
}
