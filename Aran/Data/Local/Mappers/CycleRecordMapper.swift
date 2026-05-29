import Foundation

enum CycleRecordMapper {
    static func toDomain(_ model: CycleRecordModel) -> CycleRecord {
        let events = decodeEvents(from: model.eventsData)
        let diary: DiaryEntry? = model.diaryText.map {
            DiaryEntry(date: model.date, emoji: model.diaryEmoji, content: $0)
        }
        return CycleRecord(
            id: model.id,
            cycleNumber: model.cycleNumber,
            date: model.date,
            retrievalCount: model.retrievalCount,
            fertilizedCount: model.fertilizedCount,
            frozenCount: model.frozenCount,
            embryoGrades: decodeGrades(model.embryoGradesRaw),
            events: events,
            diary: diary
        )
    }

    static func toModel(_ entity: CycleRecord) -> CycleRecordModel {
        let eventsData = encodeEvents(entity.events)
        return CycleRecordModel(
            id: entity.id,
            cycleNumber: entity.cycleNumber,
            date: entity.date,
            retrievalCount: entity.retrievalCount,
            fertilizedCount: entity.fertilizedCount,
            frozenCount: entity.frozenCount,
            embryoGradesRaw: encodeGrades(entity.embryoGrades),
            eventsData: eventsData,
            diaryEmoji: entity.diary?.emoji,
            diaryText: entity.diary?.text
        )
    }

    static func decodeGrades(_ raw: String) -> [String] {
        guard let data = raw.data(using: .utf8),
              let grades = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return grades
    }

    static func encodeGrades(_ grades: [String]) -> String {
        guard let data = try? JSONEncoder().encode(grades),
              let raw = String(data: data, encoding: .utf8) else { return "[]" }
        return raw
    }

    private static func decodeEvents(from data: Data) -> [DayEvent] {
        do {
            return try JSONDecoder().decode([DayEventDTO].self, from: data).map { $0.toDomain() }
        } catch {
            #if DEBUG
            print("[CycleRecordMapper] 이벤트 역직렬화 실패: \(error)")
            #endif
            return []
        }
    }

    private static func encodeEvents(_ events: [DayEvent]) -> Data {
        let dtos = events.map { DayEventDTO(from: $0) }
        do {
            return try JSONEncoder().encode(dtos)
        } catch {
            #if DEBUG
            print("[CycleRecordMapper] 이벤트 직렬화 실패: \(error)")
            #endif
            return Data()
        }
    }
}

private extension DayEventDTO {
    init(from event: DayEvent) {
        switch event {
        case let .hospitalVisit(note): self = .hospitalVisit(note: note)
        case .ovulation: self = .ovulation
        case .periodStart: self = .periodStart
        case let .embryoRetrieval(count): self = .embryoRetrieval(count: count)
        case let .embryoTransfer(transferID): self = .embryoTransfer(transferID: transferID)
        case let .medication(id): self = .medication(medicationID: id)
        }
    }
}
