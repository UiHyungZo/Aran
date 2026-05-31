import Foundation

struct TransferRecord: Identifiable {
    let id: UUID
    var cycleNumber: Int
    var date: Date
    var embryoGrade: String
    var embryoCount: Int
    var transferType: TransferType
    var result: TransferResult
    var memo: String?
}

enum TransferResult: String, Hashable {
    case standby = "대기중"
    case waiting = "진행중"
    case pregnant = "임신"
    case notPregnant = "비임신"
}
