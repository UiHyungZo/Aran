import Foundation
import SwiftData
import AranDomain

@Model
public final class CycleRecordModel {
    @Attribute(.unique) public var id: UUID
    public var cycleNumber: Int = 1
    public var date: Date
    public var retrievalCount: Int = 0
    public var fertilizedCount: Int = 0
    public var frozenCount: Int = 0
    public var embryoRecordsRaw: String = "[]" // JSON-encoded [String]
    public var eventsData: Data = Data() // JSON-encoded [DayEventDTO]
    public var diaryEmoji: String?
    public var diaryText: String?

    public init(
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
public enum DayEventDTO: Codable {
    case hospitalVisit(note: String?)
    case ovulation
    case periodStart
    case periodPredicted
    case embryoRetrieval(count: Int)
    case embryoTransfer(transferID: UUID)
    case medication(medicationID: UUID)

    public func toDomain() -> DayEvent {
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
