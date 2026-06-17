import Foundation
import SwiftData
import AranDomain

@Model
final class MenstrualCycleModel {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var cycleLength: Int
    var periodLength: Int = 5

    init(id: UUID = UUID(), startDate: Date, cycleLength: Int = 28, periodLength: Int = 5) {
        self.id = id
        self.startDate = startDate
        self.cycleLength = cycleLength
        self.periodLength = periodLength
    }
}
