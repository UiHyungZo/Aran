import Foundation

enum MedicationLogMapper {
    static func toDomain(_ model: MedicationLogModel) -> MedicationLog {
        MedicationLog(
            id: model.id,
            medicationId: model.medicationId,
            logDate: model.logDate,
            isTaken: model.isTaken
        )
    }

    static func toModel(_ entity: MedicationLog) -> MedicationLogModel {
        MedicationLogModel(
            id: entity.id,
            medicationId: entity.medicationId,
            logDate: entity.logDate,
            isTaken: entity.isTaken
        )
    }
}
