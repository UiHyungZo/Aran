import Foundation
import SwiftData

@Model
final class HospitalVisitModel {
    @Attribute(.unique) var id: UUID
    var visitDate: Date
    var visitTypes: [String]
    var memo: String?

    init(id: UUID = UUID(), visitDate: Date, visitTypes: [String], memo: String? = nil) {
        self.id = id
        self.visitDate = visitDate
        self.visitTypes = visitTypes
        self.memo = memo
    }
}
