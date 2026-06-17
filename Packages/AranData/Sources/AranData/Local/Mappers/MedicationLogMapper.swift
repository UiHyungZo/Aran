import Foundation
import AranDomain

public enum MedicationLogMapper {
    public static func toDomain(_ model: MedicationLogModel) -> MedicationLog {
        let resolvedSlotID = model.timeSlotID ?? MedicationLegacySlotID.make(
            medicationID: model.medicationId,
            index: model.timeIndex
        )
        return MedicationLog(
            id: model.id,
            medicationId: model.medicationId,
            logDate: model.logDate,
            isTaken: model.isTaken,
            timeSlotID: resolvedSlotID
        )
    }

    public static func toModel(_ entity: MedicationLog) -> MedicationLogModel {
        MedicationLogModel(
            id: entity.id,
            medicationId: entity.medicationId,
            logDate: entity.logDate,
            isTaken: entity.isTaken,
            timeSlotID: entity.timeSlotID
        )
    }
}
