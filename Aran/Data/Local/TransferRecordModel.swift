import Foundation
import SwiftData

@Model
final class TransferRecordModel {
    @Attribute(.unique) var id: UUID
    var cycleNumber: Int
    var date: Date
    var embryoGrade: String
    var embryoCount: Int
    var transferTypeRawValue: String
    var resultRawValue: String
    var memo: String?

    init(
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
