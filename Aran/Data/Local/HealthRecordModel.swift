import Foundation
import SwiftData

@Model
final class HealthRecordModel {
    @Attribute(.unique) var id: UUID
    var testItemRawValue: String
    var value: Double
    var date: Date
    var note: String?

    init(
        id: UUID = UUID(),
        testItemRawValue: String,
        value: Double,
        date: Date,
        note: String? = nil
    ) {
        self.id = id
        self.testItemRawValue = testItemRawValue
        self.value = value
        self.date = date
        self.note = note
    }
}
