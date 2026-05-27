import Foundation

final class CycleRecordUseCase {
    private let repository: CycleRecordRepositoryProtocol

    init(repository: CycleRecordRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() async throws -> [CycleRecord] {
        return try await repository.fetchAll()
    }

    func fetch(date: Date) async throws -> CycleRecord? {
        return try await repository.fetch(date: date)
    }

    func addEvent(_ event: DayEvent, to date: Date) async throws {
        if var existing = try await repository.fetch(date: date) {
            existing.events.append(event)
            try await repository.update(existing)
        } else {
            let record = CycleRecord(id: UUID(), date: date, events: [event], diary: nil)
            try await repository.save(record)
        }
    }

    func saveDiary(emoji: String?, text: String, for date: Date) async throws {
        let diary = DiaryEntry(date: date, emoji: emoji, content: text)
        if var existing = try await repository.fetch(date: date) {
            existing.diary = diary
            try await repository.update(existing)
        } else {
            let record = CycleRecord(id: UUID(), date: date, events: [], diary: diary)
            try await repository.save(record)
        }
    }

    func estimateOvulation(from periodStart: Date, cycleLength: Int = 28) -> Date {
        Calendar.current.date(byAdding: .day, value: cycleLength - 14, to: periodStart) ?? periodStart
    }
}
