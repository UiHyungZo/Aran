import Foundation

private struct EmbryoRecordDTO: Codable {
    let id: UUID
    let cycleId: UUID
    let stage: String
    let simpleGrade: String
    let rawGrade: String?
    let isFrozen: Bool
    let memo: String?

    func toEntity() -> EmbryoRecord {
        EmbryoRecord(
            id: id,
            cycleId: cycleId,
            stage: EmbryoStage(rawValue: stage) ?? .blastocystDay5,
            simpleGrade: EmbryoSimpleGrade(rawValue: simpleGrade) ?? .unknown,
            rawGrade: rawGrade,
            isFrozen: isFrozen,
            memo: memo
        )
    }

    init(from entity: EmbryoRecord) {
        id = entity.id
        cycleId = entity.cycleId
        stage = entity.stage.rawValue
        simpleGrade = entity.simpleGrade.rawValue
        rawGrade = entity.rawGrade
        isFrozen = entity.isFrozen
        memo = entity.memo
    }
}

enum CycleRecordMapper {
    static func toDomain(_ model: CycleRecordModel) -> CycleRecord {
        let events = decodeEvents(from: model.eventsData)
        let diary: DiaryEntry? = model.diaryText.map {
            DiaryEntry(id: UUID(), date: model.date, emoji: model.diaryEmoji, content: $0)
        }
        return CycleRecord(
            id: model.id,
            cycleNumber: model.cycleNumber,
            date: model.date,
            retrievalCount: model.retrievalCount,
            fertilizedCount: model.fertilizedCount,
            frozenCount: model.frozenCount,
            embryoRecords: decodeEmbryoRecords(model.embryoRecordsRaw),
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
            embryoRecordsRaw: encodeEmbryoRecords(entity.embryoRecords),
            eventsData: eventsData,
            diaryEmoji: entity.diary?.emoji,
            diaryText: entity.diary?.text
        )
    }

    static func decodeEmbryoRecords(_ raw: String) -> [EmbryoRecord] {
        guard let data = raw.data(using: .utf8),
              let dtos = try? JSONDecoder().decode([EmbryoRecordDTO].self, from: data) else { return [] }
        return dtos.map { $0.toEntity() }
    }

    static func encodeEmbryoRecords(_ records: [EmbryoRecord]) -> String {
        let dtos = records.map { EmbryoRecordDTO(from: $0) }
        guard let data = try? JSONEncoder().encode(dtos),
              let raw = String(data: data, encoding: .utf8) else { return "[]" }
        return raw
    }

    private static func decodeEvents(from data: Data) -> [DayEvent] {
        do {
            return try JSONDecoder().decode([DayEventDTO].self, from: data).map { $0.toDomain() }
        } catch {
            print("[CycleRecordMapper] 이벤트 역직렬화 실패: \(error)")
            return []
        }
    }

    private static func encodeEvents(_ events: [DayEvent]) -> Data {
        let dtos = events.map { DayEventDTO(from: $0) }
        do {
            return try JSONEncoder().encode(dtos)
        } catch {
            print("[CycleRecordMapper] 이벤트 직렬화 실패: \(error)")
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
        case .periodPredicted: self = .periodPredicted
        case let .embryoRetrieval(count): self = .embryoRetrieval(count: count)
        case let .embryoTransfer(transferID): self = .embryoTransfer(transferID: transferID)
        case let .medication(id): self = .medication(medicationID: id)
        }
    }
}
