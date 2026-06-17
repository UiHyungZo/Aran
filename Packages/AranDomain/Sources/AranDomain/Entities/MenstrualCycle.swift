import Foundation

public struct MenstrualCycle: Identifiable {
    public let id: UUID
    public var startDate: Date
    public var cycleLength: Int
    public var periodLength: Int

    public init(id: UUID, startDate: Date, cycleLength: Int = 28, periodLength: Int = 5) {
        self.id = id
        self.startDate = startDate
        self.cycleLength = cycleLength
        self.periodLength = periodLength
    }
}
