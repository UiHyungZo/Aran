import Foundation
import SwiftData
import AranDomain

@Model
public final class TransferRecordModel {
    @Attribute(.unique) public var id: UUID
    public var cycleNumber: Int
    public var date: Date
    public var embryoGrade: String
    public var embryoCount: Int
    public var transferTypeRawValue: String
    public var resultRawValue: String
    public var memo: String?

    public init(
        id: UUID = UUID(),
        cycleNumber: Int = 1,
        date: Date,
        embryoGrade: String,
        embryoCount: Int,
        transferTypeRawValue: String,
        resultRawValue: String,
        memo: String? = nil
    ) {
        self.id = id
        self.cycleNumber = cycleNumber
        self.date = date
        self.embryoGrade = embryoGrade
        self.embryoCount = embryoCount
        self.transferTypeRawValue = transferTypeRawValue
        self.resultRawValue = resultRawValue
        self.memo = memo
    }
}
