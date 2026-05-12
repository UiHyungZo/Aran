import Foundation

struct HealthRecord: Identifiable {
    let id: UUID
    var testItem: TestItem
    var value: Double
    var date: Date
    var note: String?
}

enum TestItem: String, CaseIterable {
    case fsh = "FSH"
    case amh = "AMH"
    case afc = "AFC"
    case e2 = "E2"
    case progesterone = "P4"
    case lh = "LH"
    case beta_hcg = "β-hCG"
    case pgt = "PGT"
    case chromosomeCouple = "부부염색체"
    case implantation = "착상 관련"

    var unit: String {
        switch self {
        case .fsh: return "mIU/mL"
        case .amh: return "ng/mL"
        case .afc: return "개"
        case .e2: return "pg/mL"
        case .progesterone: return "ng/mL"
        case .lh: return "mIU/mL"
        case .beta_hcg: return "mIU/mL"
        case .pgt, .chromosomeCouple, .implantation: return ""
        }
    }
}

struct PGTResult {
    var normal: Int
    var abnormal: Int
    var mosaic: Int
}
