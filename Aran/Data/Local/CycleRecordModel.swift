import Foundation
import SwiftData
import AranDomain

@Model
final class CycleRecordModel {
    @Attribute(.unique) var id: UUID
    var cycleNumber: Int = 1
    var date: Date
    var retrievalCount: Int = 0
    var fertilizedCount: Int = 0
    var frozenCount: Int = 0
    var embryoRecordsRaw: String = "[]" // JSON-encoded [String]
    var eventsData: Data = Data() // JSON-encoded [DayEventDTO]
    var diaryEmoji: String?
    var diaryText: String?

    init(
        id: UUID = UUID(),
        cycleNumber: Int = 1,
        date: Date,
        retrievalCount: Int = 0,
        fertilizedCount: Int = 0,
        frozenCount: Int = 0,
        embryoRecordsRaw: String = "[]",
        eventsData: Data = Data(),
        diaryEmoji: String? = nil,
        diaryText: String? = nil
    ) {
        self.id = id
        self.cycleNumber = cycleNumber
        self.date = date
        self.retrievalCount = retrievalCount
        self.fertilizedCount = fertilizedCount
        self.frozenCount = frozenCount
        self.embryoRecordsRaw = embryoRecordsRaw
        self.eventsData = eventsData
        self.diaryEmoji = diaryEmoji
        self.diaryText = diaryText
    }
}

/// Codable intermediate for DayEvent serialization
enum DayEventDTO: Codable {
    case hospitalVisit(note: String?)
    case ovulation
    case periodStart
    case periodPredicted
    case embryoRetrieval(count: Int)
    case embryoTransfer(transferID: UUID)
    case medication(medicationID: UUID)

    func toDomain() -> DayEvent {
        switch self {
        case let .hospitalVisit(note): return .hospitalVisit(note: note)
        case .ovulation: return .ovulation
        case .periodStart: return .periodStart
        case .periodPredicted: return .periodPredicted
        case let .embryoRetrieval(count): return .embryoRetrieval(count: count)
        case let .embryoTransfer(id): return .embryoTransfer(transferID: id)
        case let .medication(id): return .medication(medicationID: id)
        }
    }
}
