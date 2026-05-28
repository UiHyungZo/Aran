@testable import Aran
import Foundation

final class MockHealthRecordUseCase: HealthRecordUseCaseProtocol {
    var stubbedAll: [HealthRecord] = []
    var stubbedByType: [HealthRecord] = []
    var stubbedLatestPerItem: [String: [HealthRecord]] = [:]
    var savedRecords: [HealthRecord] = []
    var updatedRecords: [HealthRecord] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [HealthRecord] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(type: String) async throws -> [HealthRecord] {
        if let error = shouldThrow { throw error }
        return stubbedByType
    }

    func save(type: String, value: Double, unit: String, recordDate: Date, memo: String?) async throws {
        if let error = shouldThrow { throw error }
        let record = HealthRecord(id: UUID(), type: type, value: value, unit: unit, recordDate: recordDate, memo: memo)
        savedRecords.append(record)
    }

    func update(_ record: HealthRecord) async throws {
        if let error = shouldThrow { throw error }
        updatedRecords.append(record)
    }

    func fetchLatestPerItem() async throws -> [String: [HealthRecord]] {
        if let error = shouldThrow { throw error }
        return stubbedLatestPerItem
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
