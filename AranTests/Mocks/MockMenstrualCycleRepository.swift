@testable import Aran
import Foundation
import AranDomain

final class MockMenstrualCycleRepository: MenstrualCycleRepositoryProtocol {
    var cycles: [MenstrualCycle] = []

    func fetchAll() async throws -> [MenstrualCycle] {
        cycles
    }

    func fetch(date: Date) async throws -> MenstrualCycle? {
        let day = Calendar.current.startOfDay(for: date)
        return cycles.first { Calendar.current.isDate($0.startDate, inSameDayAs: day) }
    }

    func save(_ cycle: MenstrualCycle) async throws {
        cycles.append(cycle)
    }

    func update(_ cycle: MenstrualCycle) async throws {
        if let index = cycles.firstIndex(where: { $0.id == cycle.id }) {
            cycles[index] = cycle
        }
    }

    func delete(id: UUID) async throws {
        cycles.removeAll { $0.id == id }
    }
}
