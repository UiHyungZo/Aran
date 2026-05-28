@testable import Aran
import Foundation

final class MockHospitalVisitUseCase: HospitalVisitUseCaseProtocol {
    var stubbedAll: [HospitalVisit] = []
    var stubbedByDate: [HospitalVisit] = []
    var savedVisits: [HospitalVisit] = []
    var updatedVisits: [HospitalVisit] = []
    var deletedIDs: [UUID] = []
    var shouldThrow: Error?

    func fetchAll() async throws -> [HospitalVisit] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(date: Date) async throws -> [HospitalVisit] {
        if let error = shouldThrow { throw error }
        return stubbedByDate
    }

    func save(visitDate: Date, visitTypes: [String], memo: String?) async throws {
        if let error = shouldThrow { throw error }
        let visit = HospitalVisit(id: UUID(), visitDate: visitDate, visitTypes: visitTypes, memo: memo)
        savedVisits.append(visit)
    }

    func update(_ visit: HospitalVisit) async throws {
        if let error = shouldThrow { throw error }
        updatedVisits.append(visit)
    }

    func delete(id: UUID) async throws {
        if let error = shouldThrow { throw error }
        deletedIDs.append(id)
    }
}
