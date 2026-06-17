import Foundation
import AranDomain

final class MockHospitalVisitRepository: HospitalVisitRepositoryProtocol {
    var visits: [HospitalVisit] = []

    func fetchAll() async throws -> [HospitalVisit] {
        visits
    }

    func fetch(date: Date) async throws -> [HospitalVisit] {
        let day = Calendar.current.startOfDay(for: date)
        return visits.filter { Calendar.current.isDate($0.visitDate, inSameDayAs: day) }
    }

    func save(_ visit: HospitalVisit) async throws {
        visits.append(visit)
    }

    func update(_ visit: HospitalVisit) async throws {
        if let index = visits.firstIndex(where: { $0.id == visit.id }) {
            visits[index] = visit
        }
    }

    func delete(id: UUID) async throws {
        visits.removeAll { $0.id == id }
    }
}
