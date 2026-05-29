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
    case waiting = "판정 대기"
    case pregnant = "임신"
    case notPregnant = "비임신"
}
