import Foundation

public struct HospitalVisit: Identifiable {
    public let id: UUID
    public var visitDate: Date
    public var visitTypes: [String]
    public var memo: String?

    public init(id: UUID, visitDate: Date, visitTypes: [String], memo: String? = nil) {
        self.id = id
        self.visitDate = visitDate
        self.visitTypes = visitTypes
        self.memo = memo
    }
}
