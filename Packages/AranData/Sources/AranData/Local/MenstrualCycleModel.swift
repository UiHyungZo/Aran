import Foundation
import SwiftData
import AranDomain

@Model
public final class MenstrualCycleModel {
    @Attribute(.unique) public var id: UUID
    public var startDate: Date
    public var cycleLength: Int
    public var periodLength: Int = 5

    public init(id: UUID = UUID(), startDate: Date, cycleLength: Int = 28, periodLength: Int = 5) {
        self.id = id
        self.startDate = startDate
        self.cycleLength = cycleLength
        self.periodLength = periodLength
    }
}
