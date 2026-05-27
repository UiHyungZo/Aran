import Foundation

struct CycleRecord: Identifiable {
    let id: UUID
    var cycleNumber: Int = 1
    var date: Date
    var retrievalCount: Int = 0
    var fertilizedCount: Int = 0
    var frozenCount: Int = 0
    var embryoGrades: [String] = []
    var events: [DayEvent]
    var diary: DiaryEntry?
}

enum DayEvent {
    case hospitalVisit(note: String?)
    case ovulation
    case periodStart
    case embryoRetrieval(count: Int)
    case embryoTransfer(transferID: UUID)
    case medication(medicationID: UUID)

    var dotColor: String {
        switch self {
        case .hospitalVisit: return "dotHospital"
        case .ovulation: return "dotOvulation"
        case .periodStart: return "dotPeriod"
        case .embryoRetrieval: return "dotRetrieval"
        case .embryoTransfer: return "dotTransfer"
        case .medication: return "dotMedication"
        }
    }
}

struct DiaryEntry {
    var emoji: String?
    var text: String
}

enum TransferType: String {
    case fresh = "신선"
    case frozen = "동결"
}
