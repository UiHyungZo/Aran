import Foundation

enum MenstrualCycleMapper {
    static func toDomain(_ model: MenstrualCycleModel) -> MenstrualCycle {
        MenstrualCycle(id: model.id, startDate: model.startDate, cycleLength: model.cycleLength)
    }

    static func toModel(_ entity: MenstrualCycle) -> MenstrualCycleModel {
        MenstrualCycleModel(id: entity.id, startDate: entity.startDate, cycleLength: entity.cycleLength)
    }
}
