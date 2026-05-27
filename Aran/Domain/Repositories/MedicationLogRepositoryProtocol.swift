import Foundation

protocol MedicationLogRepositoryProtocol {
    func fetchAll() async throws -> [MedicationLog]
    func fetch(date: Date) async throws -> [MedicationLog]
    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog?
    func upsert(_ log: MedicationLog) async throws
    func delete(id: UUID) async throws
    func deleteLogs(for medicationId: UUID) async throws
}
