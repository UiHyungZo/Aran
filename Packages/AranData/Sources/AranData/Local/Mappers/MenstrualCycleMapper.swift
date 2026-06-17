import Foundation
import AranDomain

public enum MenstrualCycleMapper {
    public static func toDomain(_ model: MenstrualCycleModel) -> MenstrualCycle {
        MenstrualCycle(id: model.id, startDate: model.startDate, cycleLength: model.cycleLength, periodLength: model.periodLength)
    }

    public static func toModel(_ entity: MenstrualCycle) -> MenstrualCycleModel {
        MenstrualCycleModel(id: entity.id, startDate: entity.startDate, cycleLength: entity.cycleLength, periodLength: entity.periodLength)
    }
}
