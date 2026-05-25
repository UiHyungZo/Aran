@testable import Aran
import Foundation

final class MockCycleRecordRepository: CycleRecordRepositoryProtocol {
    var fetchAllResult: [CycleRecord] = []
    var fetchDateResult: CycleRecord?
    var savedRecords: [CycleRecord] = []
    var updatedRecords: [CycleRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [CycleRecord] {
        if let error = shouldThrow { throw error }
        return fetchAllResult
    }

    func fetch(date: Date) async throws -> CycleRecord? {
        if let error = shouldThrow { throw error }
        return fetchDateResult
    }

    func save(_ record: CycleRecord) async throws {
        if let error = shouldThrow { throw error }
        savedRecords.append(record)
    }

    func update(_ record: CycleRecord) async throws {
        if let error = shouldThrow { throw error }
        updatedRecords.append(record)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
