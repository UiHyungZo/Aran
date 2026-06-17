import Foundation

public struct PGTRecord: Identifiable {
    public let id: UUID
    public var cycleRecordId: UUID
    public var testDate: Date
    public var type: PGTType
    public var normalCount: Int
    public var abnormalCount: Int
    public var mosaicCount: Int
    public var inconclusiveCount: Int
    public var resultStatus: PGTResultStatus?
    public var femaleChromosomeResult: ChromosomeResult?
    public var maleChromosomeResult: ChromosomeResult?
    public var implantationTestType: ImplantationTestType?
    public var implantationResult: ImplantationResult?
    public var recommendedTransferWindow: String?
    public var memo: String?

    public init(
        id: UUID,
        cycleRecordId: UUID,
        testDate: Date,
        type: PGTType,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        inconclusiveCount: Int = 0,
        resultStatus: PGTResultStatus? = nil,
        femaleChromosomeResult: ChromosomeResult? = nil,
        maleChromosomeResult: ChromosomeResult? = nil,
        implantationTestType: ImplantationTestType? = nil,
        implantationResult: ImplantationResult? = nil,
        recommendedTransferWindow: String? = nil,
        memo: String? = nil
    ) {
        self.id = id
        self.cycleRecordId = cycleRecordId
        self.testDate = testDate
        self.type = type
        self.normalCount = normalCount
        self.abnormalCount = abnormalCount
        self.mosaicCount = mosaicCount
        self.inconclusiveCount = inconclusiveCount
        self.resultStatus = resultStatus
        self.femaleChromosomeResult = femaleChromosomeResult
        self.maleChromosomeResult = maleChromosomeResult
        self.implantationTestType = implantationTestType
        self.implantationResult = implantationResult
        self.recommendedTransferWindow = recommendedTransferWindow
        self.memo = memo
    }
}

public enum PGTType: String, CaseIterable {
    case pgtA = "PGT-A"
    case pgtM = "PGT-M"
    case chromosomeCouple = "부부염색체"
    case implantation = "반착검사"

    public var showsEmbryoCounts: Bool {
        switch self {
        case .pgtA, .pgtM:
            return true
        case .chromosomeCouple, .implantation:
            return false
        }
    }
}

public enum PGTResultStatus: String, CaseIterable {
    case normal = "정상"
    case abnormal = "이상"
    case borderline = "경계"
    case pending = "대기"
}

public enum ChromosomeResult: String, CaseIterable {
    case normal = "정상"
    case abnormal = "이상"
    case carrier = "보인자"
    case unknown = "미확인"
}

public enum ImplantationTestType: String, CaseIterable {
    case era = "ERA"
    case emma = "EMMA"
    case alice = "ALICE"
    case other = "기타"
}

public enum ImplantationResult: String, CaseIterable {
    case receptive = "수용성"
    case preReceptive = "수용 전"
    case postReceptive = "수용 후"
    case dysbiosis = "균형 이상"
    case inflammation = "염증"
    case normal = "정상"
    case abnormal = "이상"
    case unknown = "미확인"
}
