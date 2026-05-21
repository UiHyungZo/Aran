import Foundation
@testable import Aran

final class MockMedicationRepository: MedicationRepositoryProtocol {
    var fetchAllResult: [Medication] = []
    var savedMedications: [Medication] = []
    var updatedMedications: [Medication] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [Medication] {
        if let error = shouldThrow { throw error }
        return fetchAllResult
    }

    func save(_ medication: Medication) async throws {
        if let error = shouldThrow { throw error }
        savedMedications.append(medication)
    }

    func update(_ medication: Medication) async throws {
        if let error = shouldThrow { throw error }
        updatedMedications.append(medication)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
