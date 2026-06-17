import Foundation

public struct TransferRecord: Identifiable {
    public let id: UUID
    public var cycleNumber: Int
    public var date: Date
    public var embryoGrade: String
    public var embryoCount: Int
    public var transferType: TransferType
    public var result: TransferResult
    public var memo: String?

    public init(
        id: UUID,
        cycleNumber: Int,
        date: Date,
        embryoGrade: String,
        embryoCount: Int,
        transferType: TransferType,
        result: TransferResult,
        memo: String? = nil
    ) {
        self.id = id
        self.cycleNumber = cycleNumber
        self.date = date
        self.embryoGrade = embryoGrade
        self.embryoCount = embryoCount
        self.transferType = transferType
        self.result = result
        self.memo = memo
    }
}

public enum TransferResult: String, Hashable {
    case standby = "대기중"
    case waiting = "진행중"
    case pregnant = "임신"
    case notPregnant = "비임신"
}
