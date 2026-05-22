import Foundation
import SwiftData

@Model
final class HealthRecordModel {
    @Attribute(.unique) var id: UUID
    var testItemRawValue: String
    var value: Double
    var date: Date
    var note: String?
    var pgtNormal: Int?
    var pgtAbnormal: Int?
    var pgtMosaic: Int?

    init(
        id: UUID = UUID(),
        testItemRawValue: String,
        value: Double,
        date: Date,
        note: String? = nil,
        pgtNormal: Int? = nil,
        pgtAbnormal: Int? = nil,
        pgtMosaic: Int? = nil
    ) {
        self.id = id
        self.testItemRawValue = testItemRawValue
        self.value = value
        self.date = date
        self.note = note
        self.pgtNormal = pgtNormal
        self.pgtAbnormal = pgtAbnormal
        self.pgtMosaic = pgtMosaic
    }
}
