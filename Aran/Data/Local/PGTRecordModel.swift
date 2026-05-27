import Foundation
import SwiftData

@Model
final class PGTRecordModel {
    @Attribute(.unique) var id: UUID
    var cycleRecordId: UUID
    var testDate: Date
    var typeRawValue: String
    var normalCount: Int
    var abnormalCount: Int
    var mosaicCount: Int
    var memo: String?

    init(
        id: UUID = UUID(),
        cycleRecordId: UUID,
        testDate: Date,
        typeRawValue: String,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        memo: String? = nil
    ) {
        self.id = id
        self.cycleRecordId = cycleRecordId
        self.testDate = testDate
        self.typeRawValue = typeRawValue
        self.normalCount = normalCount
        self.abnormalCount = abnormalCount
        self.mosaicCount = mosaicCount
        self.memo = memo
    }
}
