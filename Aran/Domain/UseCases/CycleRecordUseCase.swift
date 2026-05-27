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

    func save(
        cycleNumber: Int,
        startDate: Date,
        retrievalCount: Int,
        fertilizedCount: Int,
        frozenCount: Int,
        embryoGrades: [String]
    ) async throws {
        guard cycleNumber > 0 else {
            throw AppError.invalidInput("차수는 1 이상이어야 합니다.")
        }
        guard retrievalCount >= 0, fertilizedCount >= 0, frozenCount >= 0 else {
            throw AppError.invalidInput("개수는 0 이상이어야 합니다.")
        }
        guard fertilizedCount <= retrievalCount else {
            throw AppError.invalidInput("수정 개수는 채취 개수보다 많을 수 없습니다.")
        }
        guard frozenCount <= fertilizedCount else {
            throw AppError.invalidInput("동결 개수는 수정 개수보다 많을 수 없습니다.")
        }

        let record = CycleRecord(
            id: UUID(),
            cycleNumber: cycleNumber,
            date: startDate,
            retrievalCount: retrievalCount,
            fertilizedCount: fertilizedCount,
            frozenCount: frozenCount,
            embryoGrades: embryoGrades,
            events: retrievalCount > 0 ? [.embryoRetrieval(count: retrievalCount)] : [],
            diary: nil
        )
        try await repository.save(record)
    }

    func addEvent(_ event: DayEvent, to date: Date, cycleNumber: Int = 1) async throws {
        if var existing = try await repository.fetch(date: date) {
            existing.events.append(event)
            if case let .embryoRetrieval(count) = event {
                existing.retrievalCount += count
            }
            try await repository.update(existing)
        } else {
            let retrievalCount: Int
            if case let .embryoRetrieval(count) = event {
                retrievalCount = count
            } else {
                retrievalCount = 0
            }
            let record = CycleRecord(
                id: UUID(),
                cycleNumber: cycleNumber,
                date: date,
                retrievalCount: retrievalCount,
                events: [event],
                diary: nil
            )
            try await repository.save(record)
        }
    }

    func saveDiary(emoji: String?, text: String, for date: Date) async throws {
        let diary = DiaryEntry(emoji: emoji, text: text)
        if var existing = try await repository.fetch(date: date) {
            existing.diary = diary
            try await repository.update(existing)
        } else {
            let record = CycleRecord(id: UUID(), date: date, events: [], diary: diary)
            try await repository.save(record)
        }
    }

    func estimateOvulation(from periodStart: Date) -> Date {
        // 표준 28일 주기 기준 14일째 배란 추정
        Calendar.current.date(byAdding: .day, value: 14, to: periodStart) ?? periodStart
    }
}
