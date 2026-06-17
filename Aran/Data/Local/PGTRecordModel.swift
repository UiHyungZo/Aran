import Foundation
import SwiftData
import AranDomain

@Model
final class PGTRecordModel {
    @Attribute(.unique) var id: UUID
    var cycleRecordId: UUID
    var testDate: Date
    var typeRawValue: String
    var normalCount: Int
    var abnormalCount: Int
    var mosaicCount: Int
    var inconclusiveCount: Int = 0
    var resultStatusRawValue: String?
    var femaleChromosomeResultRawValue: String?
    var maleChromosomeResultRawValue: String?
    var implantationTestTypeRawValue: String?
    var implantationResultRawValue: String?
    var recommendedTransferWindow: String?
    var memo: String?

    init(
        id: UUID = UUID(),
        cycleRecordId: UUID,
        testDate: Date,
        typeRawValue: String,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        inconclusiveCount: Int = 0,
        resultStatusRawValue: String? = nil,
        femaleChromosomeResultRawValue: String? = nil,
        maleChromosomeResultRawValue: String? = nil,
        implantationTestTypeRawValue: String? = nil,
        implantationResultRawValue: String? = nil,
        recommendedTransferWindow: String? = nil,
        memo: String? = nil
    ) {
        self.id = id
        self.cycleRecordId = cycleRecordId
        self.testDate = testDate
        self.typeRawValue = typeRawValue
        self.normalCount = normalCount
        self.abnormalCount = abnormalCount
        self.mosaicCount = mosaicCount
        self.inconclusiveCount = inconclusiveCount
        self.resultStatusRawValue = resultStatusRawValue
        self.femaleChromosomeResultRawValue = femaleChromosomeResultRawValue
        self.maleChromosomeResultRawValue = maleChromosomeResultRawValue
        self.implantationTestTypeRawValue = implantationTestTypeRawValue
        self.implantationResultRawValue = implantationResultRawValue
        self.recommendedTransferWindow = recommendedTransferWindow
        self.memo = memo
    }
}
