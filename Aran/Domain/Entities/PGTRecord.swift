import Foundation

struct PGTRecord: Identifiable {
    let id: UUID
    var cycleRecordId: UUID
    var testDate: Date
    var type: PGTType
    var normalCount: Int
    var abnormalCount: Int
    var mosaicCount: Int
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
