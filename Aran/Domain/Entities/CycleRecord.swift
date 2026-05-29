import Foundation

enum EmbryoStage: String, Codable, CaseIterable {
    case cleavageDay3 = "3일배아"
    case blastocystDay5 = "5일배아"
}

enum EmbryoSimpleGrade: String, Codable, CaseIterable {
    case high = "상"
    case midHigh = "중상"
    case medium = "중"
    case midLow = "중하"
    case low = "하"
    case unknown = "미입력"
}

struct EmbryoRecord: Identifiable, Codable {
    let id: UUID
    let cycleId: UUID
    var stage: EmbryoStage
    var simpleGrade: EmbryoSimpleGrade
    var rawGrade: String?
    var isFrozen: Bool
    var memo: String?
}

struct CycleRecord: Identifiable {
    let id: UUID
    var cycleNumber: Int = 1
    var date: Date
    var retrievalCount: Int = 0
    var fertilizedCount: Int = 0
    var frozenCount: Int = 0
    var embryoRecords: [EmbryoRecord] = []
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

enum TransferType: String, Hashable {
    case fresh = "신선"
    case frozen = "동결"
}
