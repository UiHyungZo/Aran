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
    case pending = "진행중"
    case success = "성공"
    case failed = "실패"
}
