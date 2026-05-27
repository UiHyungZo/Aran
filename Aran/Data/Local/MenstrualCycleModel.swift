import Foundation
import SwiftData

@Model
final class MenstrualCycleModel {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var cycleLength: Int

    init(id: UUID = UUID(), startDate: Date, cycleLength: Int = 28) {
        self.id = id
        self.startDate = startDate
        self.cycleLength = cycleLength
    }
}
