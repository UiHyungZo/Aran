import Foundation
import AranDomain

final class MockMedicationRepository: MedicationRepositoryProtocol {
    var fetchAllResult: [Medication] = []
    var savedMedications: [Medication] = []
    var updatedMedications: [Medication] = []
    var deletedIDs: [UUID] = []
    var addedSlots: [(slot: MedicationTimeSlot, medicationId: UUID)] = []
    var removedSlots: [(slotId: UUID, medicationId: UUID)] = []
    var updatedSlots: [MedicationTimeSlot] = []
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

    func addTimeSlot(_ slot: MedicationTimeSlot, to medicationId: UUID) async throws {
        if let error = shouldThrow { throw error }
        addedSlots.append((slot, medicationId))
    }

    func removeTimeSlot(_ slotId: UUID, from medicationId: UUID) async throws {
        if let error = shouldThrow { throw error }
        removedSlots.append((slotId, medicationId))
    }

    func updateTimeSlot(_ slot: MedicationTimeSlot) async throws {
        if let error = shouldThrow { throw error }
        updatedSlots.append(slot)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
