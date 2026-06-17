import Foundation
import SwiftData
import AranDomain

@Model
public final class HospitalVisitModel {
    @Attribute(.unique) public var id: UUID
    public var visitDate: Date
    public var visitTypes: [String]
    public var memo: String?

    public init(id: UUID = UUID(), visitDate: Date, visitTypes: [String], memo: String? = nil) {
        self.id = id
        self.visitDate = visitDate
        self.visitTypes = visitTypes
        self.memo = memo
    }
}
