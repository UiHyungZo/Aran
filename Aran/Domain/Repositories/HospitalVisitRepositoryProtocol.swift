import Foundation

protocol HospitalVisitRepositoryProtocol {
    func fetchAll() async throws -> [HospitalVisit]
    func fetch(date: Date) async throws -> [HospitalVisit]
    func save(_ visit: HospitalVisit) async throws
    func update(_ visit: HospitalVisit) async throws
    func delete(id: UUID) async throws
}
