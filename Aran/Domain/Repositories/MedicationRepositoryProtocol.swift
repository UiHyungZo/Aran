import Foundation

protocol MedicationRepositoryProtocol {
    func fetchAll() async throws -> [Medication]
    func save(_ medication: Medication) async throws
    func update(_ medication: Medication) async throws
    func addTimeSlot(_ slot: MedicationTimeSlot, to medicationId: UUID) async throws
    func removeTimeSlot(_ slotId: UUID, from medicationId: UUID) async throws
    func updateTimeSlot(_ slot: MedicationTimeSlot) async throws
    func delete(id: UUID) async throws
}
