import Foundation
import SwiftData
import AranDomain

@Model
public final class HealthRecordModel {
    @Attribute(.unique) public var id: UUID
    public var type: String
    public var value: Double
    public var unit: String
    public var recordDate: Date
    public var memo: String?

    public init(
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
