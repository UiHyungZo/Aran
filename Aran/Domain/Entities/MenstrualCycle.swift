import Foundation

struct MenstrualCycle: Identifiable {
    let id: UUID
    var startDate: Date
    var cycleLength: Int
    var periodLength: Int

    init(id: UUID, startDate: Date, cycleLength: Int = 28, periodLength: Int = 5) {
        self.id = id
        self.startDate = startDate
        self.cycleLength = cycleLength
        self.periodLength = periodLength
    }
}
