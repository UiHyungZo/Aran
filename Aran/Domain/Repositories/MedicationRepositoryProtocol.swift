import Foundation

protocol MedicationRepositoryProtocol {
    func fetchAll() async throws -> [Medication]
    func save(_ medication: Medication) async throws
    func update(_ medication: Medication) async throws
    func delete(id: UUID) async throws
}
