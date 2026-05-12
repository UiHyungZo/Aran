import Foundation

enum MedicationMapper {
    static func toDomain(_ model: MedicationModel) -> Medication {
        Medication(
            id: model.id,
            drugName: model.drugName,
            dosage: model.dosage,
            type: MedicationType(rawValue: model.typeRawValue) ?? .other,
            schedule: MedicationSchedule(
                times: model.scheduleTimes,
                startDate: model.scheduleStartDate,
                endDate: model.scheduleEndDate
            ),
            isEnabled: model.isEnabled,
            notificationIDs: model.notificationIDs,
            createdAt: model.createdAt
        )
    }

    static func toModel(_ entity: Medication) -> MedicationModel {
        MedicationModel(
            id: entity.id,
            drugName: entity.drugName,
            dosage: entity.dosage,
            typeRawValue: entity.type.rawValue,
            scheduleTimes: entity.schedule.times,
            scheduleStartDate: entity.schedule.startDate,
            scheduleEndDate: entity.schedule.endDate,
            isEnabled: entity.isEnabled,
            notificationIDs: entity.notificationIDs,
            createdAt: entity.createdAt
        )
    }
}
