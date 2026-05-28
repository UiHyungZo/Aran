@testable import Aran
import Foundation

final class MockMenstrualCycleUseCase: MenstrualCycleUseCaseProtocol {
    var stubbedAll: [MenstrualCycle] = []
    var stubbedCycle: MenstrualCycle?
    var shouldThrow: Error?

    func fetchAll() async throws -> [MenstrualCycle] {
        if let error = shouldThrow { throw error }
        return stubbedAll
    }

    func fetch(date: Date) async throws -> MenstrualCycle? {
        if let error = shouldThrow { throw error }
        return stubbedCycle
    }

    func save(startDate: Date, cycleLength: Int) async throws {
        if let error = shouldThrow { throw error }
    }

    func calculateOvulationDate(startDate: Date, cycleLength: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: cycleLength - 14, to: startDate) ?? startDate
    }

    func periodDates(for cycle: MenstrualCycle) -> [Date] {
        (0 ..< cycle.cycleLength).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: cycle.startDate)
        }
    }
}
