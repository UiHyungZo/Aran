import Foundation

public enum EmbryoStage: String, Codable, CaseIterable {
    case cleavageDay3 = "3일배아"
    case morulaDy4 = "4일배아"
    case blastocystDay5 = "5일배아"
    case blastocystDay6 = "6일배아"
    case blastocystDay7 = "7일배아"

    public var displayName: String {
        switch self {
        case .cleavageDay3:   return "3일 배아"
        case .morulaDy4:      return "4일 배아"
        case .blastocystDay5: return "5일 배아"
        case .blastocystDay6: return "6일 배아"
        case .blastocystDay7: return "7일 배아"
        }
    }
}

public enum EmbryoSimpleGrade: String, Codable, CaseIterable {
    case high = "상"
    case midHigh = "중상"
    case medium = "중"
    case midLow = "중하"
    case low = "하"
    case unknown = "미입력"
}

public struct EmbryoRecord: Identifiable, Codable {
    public let id: UUID
    public let cycleId: UUID
    public var stage: EmbryoStage
    public var simpleGrade: EmbryoSimpleGrade
    public var rawGrade: String?
    public var isFrozen: Bool
    public var memo: String?

    public init(
        id: UUID,
        cycleId: UUID,
        stage: EmbryoStage,
        simpleGrade: EmbryoSimpleGrade,
        rawGrade: String? = nil,
        isFrozen: Bool,
        memo: String? = nil
    ) {
        self.id = id
        self.cycleId = cycleId
        self.stage = stage
        self.simpleGrade = simpleGrade
        self.rawGrade = rawGrade
        self.isFrozen = isFrozen
        self.memo = memo
    }
}

public struct CycleRecord: Identifiable {
    public let id: UUID
    public var cycleNumber: Int
    public var date: Date
    public var retrievalCount: Int
    public var fertilizedCount: Int
    public var frozenCount: Int
    public var embryoRecords: [EmbryoRecord]
    public var events: [DayEvent]
    public var diary: DiaryEntry?

    public init(
        id: UUID,
        cycleNumber: Int = 1,
        date: Date,
        retrievalCount: Int = 0,
        fertilizedCount: Int = 0,
        frozenCount: Int = 0,
        embryoRecords: [EmbryoRecord] = [],
        events: [DayEvent],
        diary: DiaryEntry? = nil
    ) {
        self.id = id
        self.cycleNumber = cycleNumber
        self.date = date
        self.retrievalCount = retrievalCount
        self.fertilizedCount = fertilizedCount
        self.frozenCount = frozenCount
        self.embryoRecords = embryoRecords
        self.events = events
        self.diary = diary
    }
}

public enum DayEvent {
    case hospitalVisit(note: String?)
    case ovulation
    case periodStart
    case periodPredicted
    case embryoRetrieval(count: Int)
    case embryoTransfer(transferID: UUID)
    case medication(medicationID: UUID)

    public var dotColor: String {
        switch self {
        case .hospitalVisit: return "dotHospital"
        case .ovulation: return "dotOvulation"
        case .periodStart: return "dotPeriod"
        case .periodPredicted: return "dotPeriodPredicted"
        case .embryoRetrieval: return "dotRetrieval"
        case .embryoTransfer: return "dotTransfer"
        case .medication: return "dotMedication"
        }
    }
}

public enum TransferType: String, Hashable {
    case fresh = "신선"
    case frozen = "동결"
}
