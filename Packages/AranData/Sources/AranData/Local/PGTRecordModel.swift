import Foundation
import SwiftData
import AranDomain

@Model
public final class PGTRecordModel {
    @Attribute(.unique) public var id: UUID
    public var cycleRecordId: UUID
    public var testDate: Date
    public var typeRawValue: String
    public var normalCount: Int
    public var abnormalCount: Int
    public var mosaicCount: Int
    public var inconclusiveCount: Int = 0
    public var resultStatusRawValue: String?
    public var femaleChromosomeResultRawValue: String?
    public var maleChromosomeResultRawValue: String?
    public var implantationTestTypeRawValue: String?
    public var implantationResultRawValue: String?
    public var recommendedTransferWindow: String?
    public var memo: String?

    public init(
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
