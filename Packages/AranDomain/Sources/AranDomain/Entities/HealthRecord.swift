import Foundation

public struct HealthRecord: Identifiable {
    public let id: UUID
    public var type: String
    public var value: Double
    public var unit: String
    public var recordDate: Date
    public var memo: String?

    public init(id: UUID, type: String, value: Double, unit: String, recordDate: Date, memo: String? = nil) {
        self.id = id
        self.type = type
        self.value = value
        self.unit = unit
        self.recordDate = recordDate
        self.memo = memo
    }
}

public enum HealthRecordType {
    public static let fsh = "FSH"
    public static let amh = "AMH"
    public static let afc = "AFC"
    public static let e2 = "E2"
    public static let p4 = "P4"
    public static let lh = "LH"
    public static let betaHCG = "β-hCG"

    public static let defaults: [String] = [fsh, amh, afc, e2, p4, lh, betaHCG]

    public static let defaultUnits: [String: String] = [
        fsh: "mIU/mL",
        amh: "ng/mL",
        afc: "개",
        e2: "pg/mL",
        p4: "ng/mL",
        lh: "mIU/mL",
        betaHCG: "mIU/mL",
    ]
}
