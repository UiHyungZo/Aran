@testable import Aran
import Foundation

final class MockMedicationUseCase: MedicationUseCaseProtocol {
    var stubbedMedications: [Medication] = []
    var savedMedications: [Medication] = []
    var updatedMedications: [Medication] = []
    var toggledMedications: [Medication] = []
    var deletedMedications: [Medication] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [Medication] {
        if let error = shouldThrow { throw error }
        return stubbedMedications
    }

    func save(_ medication: Medication) async throws {
        if let error = shouldThrow { throw error }
        savedMedications.append(medication)
    }

    func update(_ medication: Medication) async throws {
        if let error = shouldThrow { throw error }
        updatedMedications.append(medication)
    }

    func toggle(medication: Medication) async throws {
        if let error = shouldThrow { throw error }
        toggledMedications.append(medication)
    }

    func delete(medication: Medication) async throws {
        if let error = shouldThrow { throw error }
        deletedMedications.append(medication)
    }
}
