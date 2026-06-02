import Foundation

protocol MenstrualCycleUseCaseProtocol {
    func fetchAll() async throws -> [MenstrualCycle]
    func fetch(date: Date) async throws -> MenstrualCycle?
    func save(startDate: Date, cycleLength: Int, periodLength: Int) async throws
    func delete(id: UUID) async throws
    func calculateOvulationDate(startDate: Date, cycleLength: Int) -> Date
    func periodDates(for cycle: MenstrualCycle) -> [Date]
    func nextPeriodDate(after cycle: MenstrualCycle) -> Date
}

final class MenstrualCycleUseCase: MenstrualCycleUseCaseProtocol {
    private let repository: MenstrualCycleRepositoryProtocol

    init(repository: MenstrualCycleRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [MenstrualCycle] {
        try await repository.fetchAll()
    }

    func fetch(date: Date) async throws -> MenstrualCycle? {
        try await repository.fetch(date: date)
    }

    func save(startDate: Date, cycleLength: Int = 28, periodLength: Int = 5) async throws {
        guard (21 ... 42).contains(cycleLength) else {
            throw AppError.invalidInput("생리 주기는 21일에서 42일 사이로 입력해주세요.")
        }
        guard (2 ... 10).contains(periodLength) else {
            throw AppError.invalidInput("생리 기간은 2일에서 10일 사이로 입력해주세요.")
        }
        if var existing = try await repository.fetch(date: startDate) {
            existing.cycleLength = cycleLength
            existing.periodLength = periodLength
            try await repository.update(existing)
        } else {
            try await repository.save(MenstrualCycle(id: UUID(), startDate: startDate, cycleLength: cycleLength, periodLength: periodLength))
        }
    }

    func delete(id: UUID) async throws {
        try await repository.delete(id: id)
    }

    func calculateOvulationDate(startDate: Date, cycleLength: Int = 28) -> Date {
        Calendar.current.date(byAdding: .day, value: cycleLength - 14, to: startDate) ?? startDate
    }

    func periodDates(for cycle: MenstrualCycle) -> [Date] {
        (0..<cycle.periodLength).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: cycle.startDate)
        }
    }

    func nextPeriodDate(after cycle: MenstrualCycle) -> Date {
        Calendar.current.date(byAdding: .day, value: cycle.cycleLength, to: cycle.startDate) ?? cycle.startDate
    }
}
