@testable import Aran
import Foundation

final class MockTransferRecordRepository: TransferRecordRepositoryProtocol {
    var fetchAllResult: [TransferRecord] = []
    var fetchByIDResult: TransferRecord?
    var fetchByDateResult: [TransferRecord] = []
    var savedRecords: [TransferRecord] = []
    var updatedRecords: [TransferRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [TransferRecord] {
        if let error = shouldThrow { throw error }
        return fetchAllResult
    }

    func fetch(id: UUID) async throws -> TransferRecord? {
        if let error = shouldThrow { throw error }
        return fetchByIDResult
    }

    func fetch(for date: Date) async throws -> [TransferRecord] {
        if let error = shouldThrow { throw error }
        return fetchByDateResult
    }

    func save(_ record: TransferRecord) async throws {
        if let error = shouldThrow { throw error }
        savedRecords.append(record)
    }

    func update(_ record: TransferRecord) async throws {
        if let error = shouldThrow { throw error }
        updatedRecords.append(record)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
