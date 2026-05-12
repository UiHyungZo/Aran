import Foundation
import SwiftData

@Model
final class CycleRecordModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var eventsData: Data   // JSON-encoded [DayEventDTO]
    var diaryEmoji: String?
    var diaryText: String?

    init(
        id: UUID = UUID(),
        date: Date,
        eventsData: Data = Data(),
        diaryEmoji: String? = nil,
        diaryText: String? = nil
    ) {
        self.id = id
        self.date = date
        self.eventsData = eventsData
        self.diaryEmoji = diaryEmoji
        self.diaryText = diaryText
    }
}

// Codable intermediate for DayEvent serialization
enum DayEventDTO: Codable {
    case hospitalVisit(note: String?)
    case ovulation
    case periodStart
    case embryoRetrieval(count: Int)
    case embryoTransfer(count: Int, type: String)
    case medication(medicationID: UUID)

    func toDomain() -> DayEvent {
        switch self {
        case let .hospitalVisit(note): return .hospitalVisit(note: note)
        case .ovulation: return .ovulation
        case .periodStart: return .periodStart
        case let .embryoRetrieval(count): return .embryoRetrieval(count: count)
        case let .embryoTransfer(count, type): return .embryoTransfer(count: count, type: TransferType(rawValue: type) ?? .fresh)
        case let .medication(id): return .medication(medicationID: id)
        }
    }
}
