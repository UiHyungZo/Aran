@testable import Aran
import Foundation
import AranDomain

final class MockHealthRecordRepository: HealthRecordRepositoryProtocol {
    var fetchAllResult: [HealthRecord] = []
    var fetchTypeResult: [HealthRecord] = []
    var savedRecords: [HealthRecord] = []
    var updatedRecords: [HealthRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [HealthRecord] {
        if let error = shouldThrow { throw error }
        return fetchAllResult
    }

    func fetch(type: String) async throws -> [HealthRecord] {
        if let error = shouldThrow { throw error }
        return fetchTypeResult
    }

    func save(_ record: HealthRecord) async throws {
        if let error = shouldThrow { throw error }
        savedRecords.append(record)
    }

    func update(_ record: HealthRecord) async throws {
        if let error = shouldThrow { throw error }
        updatedRecords.append(record)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
