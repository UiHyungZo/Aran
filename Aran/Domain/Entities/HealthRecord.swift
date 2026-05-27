import Foundation

struct HealthRecord: Identifiable {
    let id: UUID
    var type: String
    var value: Double
    var unit: String
    var recordDate: Date
    var memo: String?
}

enum HealthRecordType {
    static let fsh = "FSH"
    static let amh = "AMH"
    static let afc = "AFC"
    static let e2 = "E2"
    static let p4 = "P4"
    static let lh = "LH"
    static let betaHCG = "β-hCG"

    static let defaults: [String] = [fsh, amh, afc, e2, p4, lh, betaHCG]

    static let defaultUnits: [String: String] = [
        fsh: "mIU/mL",
        amh: "ng/mL",
        afc: "개",
        e2: "pg/mL",
        p4: "ng/mL",
        lh: "mIU/mL",
        betaHCG: "mIU/mL",
    ]
}
