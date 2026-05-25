@testable import Aran
import Foundation

final class MockHealthRecordRepository: HealthRecordRepositoryProtocol {
    var fetchAllResult: [HealthRecord] = []
    var fetchItemResult: [HealthRecord] = []
    var savedRecords: [HealthRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [HealthRecord] {
        if let error = shouldThrow { throw error }
        return fetchAllResult
    }

    func fetch(item: TestItem) async throws -> [HealthRecord] {
        if let error = shouldThrow { throw error }
        return fetchItemResult
    }

    func save(_ record: HealthRecord) async throws {
        if let error = shouldThrow { throw error }
        savedRecords.append(record)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
