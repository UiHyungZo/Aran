import Foundation

struct PGTRecord: Identifiable {
    let id: UUID
    var cycleRecordId: UUID
    var testDate: Date
    var type: PGTType
    var normalCount: Int
    var abnormalCount: Int
    var mosaicCount: Int
    var inconclusiveCount: Int = 0
    var resultStatus: PGTResultStatus?
    var femaleChromosomeResult: ChromosomeResult?
    var maleChromosomeResult: ChromosomeResult?
    var implantationTestType: ImplantationTestType?
    var implantationResult: ImplantationResult?
    var recommendedTransferWindow: String?
    var memo: String?
}

enum PGTType: String, CaseIterable {
    case pgtA = "PGT-A"
    case pgtM = "PGT-M"
    case chromosomeCouple = "부부염색체"
    case implantation = "반착검사"

    var showsEmbryoCounts: Bool {
        switch self {
        case .pgtA, .pgtM:
            return true
        case .chromosomeCouple, .implantation:
            return false
        }
    }
}

enum PGTResultStatus: String, CaseIterable {
    case normal = "정상"
    case abnormal = "이상"
    case borderline = "경계"
    case pending = "대기"
}

enum ChromosomeResult: String, CaseIterable {
    case normal = "정상"
    case abnormal = "이상"
    case carrier = "보인자"
    case unknown = "미확인"
}

enum ImplantationTestType: String, CaseIterable {
    case era = "ERA"
    case emma = "EMMA"
    case alice = "ALICE"
    case other = "기타"
}

enum ImplantationResult: String, CaseIterable {
    case receptive = "수용성"
    case preReceptive = "수용 전"
    case postReceptive = "수용 후"
    case dysbiosis = "균형 이상"
    case inflammation = "염증"
    case normal = "정상"
    case abnormal = "이상"
    case unknown = "미확인"
}
