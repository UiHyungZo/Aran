import Foundation

enum CycleRecordMapper {
    static func toDomain(_ model: CycleRecordModel) -> CycleRecord {
        let events = decodeEvents(from: model.eventsData)
        let diary: DiaryEntry? = model.diaryText.map { DiaryEntry(emoji: model.diaryEmoji, text: $0) }
        return CycleRecord(id: model.id, date: model.date, events: events, diary: diary)
    }

    static func toModel(_ entity: CycleRecord) -> CycleRecordModel {
        let eventsData = encodeEvents(entity.events)
        return CycleRecordModel(
            id: entity.id,
            date: entity.date,
            eventsData: eventsData,
            diaryEmoji: entity.diary?.emoji,
            diaryText: entity.diary?.text
        )
    }

    private static func decodeEvents(from data: Data) -> [DayEvent] {
        (try? JSONDecoder().decode([DayEventDTO].self, from: data))?.map { $0.toDomain() } ?? []
    }

    private static func encodeEvents(_ events: [DayEvent]) -> Data {
        let dtos = events.map { DayEventDTO(from: $0) }
        return (try? JSONEncoder().encode(dtos)) ?? Data()
    }
}

private extension DayEventDTO {
    init(from event: DayEvent) {
        switch event {
        case let .hospitalVisit(note): self = .hospitalVisit(note: note)
        case .ovulation: self = .ovulation
        case .periodStart: self = .periodStart
        case let .embryoRetrieval(count): self = .embryoRetrieval(count: count)
        case let .embryoTransfer(count, type): self = .embryoTransfer(count: count, type: type.rawValue)
        case let .medication(id): self = .medication(medicationID: id)
        }
    }
}
