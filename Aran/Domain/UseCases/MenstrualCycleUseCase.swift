import Foundation

final class MenstrualCycleUseCase {
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

    func save(startDate: Date, cycleLength: Int = 28) async throws {
        guard (21 ... 42).contains(cycleLength) else {
            throw AppError.invalidInput("생리 주기는 21일에서 42일 사이로 입력해주세요.")
        }
        if var existing = try await repository.fetch(date: startDate) {
            existing.cycleLength = cycleLength
            try await repository.update(existing)
        } else {
            try await repository.save(MenstrualCycle(startDate: startDate, cycleLength: cycleLength))
        }
    }

    func calculateOvulationDate(startDate: Date, cycleLength: Int = 28) -> Date {
        Calendar.current.date(byAdding: .day, value: cycleLength - 14, to: startDate) ?? startDate
    }

    func periodDates(for cycle: MenstrualCycle) -> [Date] {
        (0..<cycle.cycleLength).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: cycle.startDate)
        }
    }
}
