@testable import Aran
import Foundation
import AranDomain

final class MockTransferRecordUseCase: TransferRecordUseCaseProtocol {
    var stubbedAll: [TransferRecord] = []
    var stubbedRecord: TransferRecord?
    var stubbedByDate: [TransferRecord] = []
    var savedRecords: [TransferRecord] = []
    var updatedRecords: [TransferRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [TransferRecord] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(id: UUID) async throws -> TransferRecord? {
        if let error = shouldThrow { throw error }
        return stubbedRecord
    }

    func fetch(for date: Date) async throws -> [TransferRecord] {
        if let error = shouldThrow { throw error }
        return stubbedByDate
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
