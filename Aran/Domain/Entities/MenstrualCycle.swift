import Foundation

struct MenstrualCycle: Identifiable {
    let id: UUID
    var startDate: Date
    var cycleLength: Int

    init(id: UUID = UUID(), startDate: Date, cycleLength: Int = 28) {
        self.id = id
        self.startDate = startDate
        self.cycleLength = cycleLength
    }
}
