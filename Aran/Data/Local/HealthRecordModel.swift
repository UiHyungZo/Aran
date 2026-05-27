import Foundation
import SwiftData

@Model
final class HealthRecordModel {
    @Attribute(.unique) var id: UUID
    var type: String
    var value: Double
    var unit: String
    var recordDate: Date
    var memo: String?

    init(
        id: UUID = UUID(),
        type: String,
        value: Double,
        unit: String,
        recordDate: Date,
        memo: String? = nil
    ) {
        self.id = id
        self.type = type
        self.value = value
        self.unit = unit
        self.recordDate = recordDate
        self.memo = memo
    }
}
