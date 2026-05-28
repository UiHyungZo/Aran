@testable import Aran
import Foundation

final class MockMedicationLogUseCase: MedicationLogUseCaseProtocol {
    var stubbedAll: [MedicationLog] = []
    var stubbedByDate: [MedicationLog] = []
    var stubbedByMedication: MedicationLog?
    var toggledItems: [(UUID, Date, UUID)] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [MedicationLog] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(date: Date) async throws -> [MedicationLog] {
        if let error = shouldThrow { throw error }
        return stubbedByDate
    }

    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog? {
        if let error = shouldThrow { throw error }
        return stubbedByMedication
    }

    func toggle(medicationId: UUID, date: Date, timeSlotID: UUID) async throws {
        if let error = shouldThrow { throw error }
        toggledItems.append((medicationId, date, timeSlotID))
    }
}
