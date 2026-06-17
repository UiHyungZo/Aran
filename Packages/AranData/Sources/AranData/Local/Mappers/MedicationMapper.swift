import Foundation
import AranDomain

public enum MedicationMapper {
    public static func toDomain(_ model: MedicationModel) -> Medication {
        let slots: [MedicationTimeSlot]
        if model.timeSlots.isEmpty {
            let sortedLegacyTimes = model.scheduleTimes.sorted {
                let calendar = Calendar.current
                let lhsMinute = calendar.component(.hour, from: $0) * 60 + calendar.component(.minute, from: $0)
                let rhsMinute = calendar.component(.hour, from: $1) * 60 + calendar.component(.minute, from: $1)
                return lhsMinute < rhsMinute
            }
            slots = sortedLegacyTimes.enumerated().map { offset, time in
                MedicationTimeSlot(
                    id: MedicationLegacySlotID.make(medicationID: model.id, index: offset),
                    time: time,
                    isEnabled: model.isEnabled,
                    medicationID: model.id
                )
            }
        } else {
            slots = model.timeSlots.map {
                MedicationTimeSlot(
                    id: $0.id,
                    time: $0.time,
                    isEnabled: $0.isEnabled,
                    medicationID: model.id
                )
            }
        }

        return Medication(
            id: model.id,
            drugName: model.drugName,
            dosage: model.dosage,
            component: model.component,
            type: MedicationType(rawValue: model.typeRawValue) ?? .other,
            schedule: MedicationSchedule(
                timeSlots: slots,
                startDate: model.scheduleStartDate,
                endDate: model.scheduleEndDate
            ),
            isEnabled: model.isEnabled,
            notificationIDs: model.notificationIDs,
            createdAt: model.createdAt
        )
    }

    public static func toModel(_ entity: Medication) -> MedicationModel {
        let slotModels = entity.schedule.timeSlots.map {
            MedicationTimeSlotModel(id: $0.id, time: $0.time, isEnabled: $0.isEnabled)
        }
        return MedicationModel(
            id: entity.id,
            drugName: entity.drugName,
            dosage: entity.dosage,
            component: entity.component,
            typeRawValue: entity.type.rawValue,
            scheduleTimes: entity.schedule.timeSlots.map(\.time),
            timeSlots: slotModels,
            scheduleStartDate: entity.schedule.startDate,
            scheduleEndDate: entity.schedule.endDate,
            isEnabled: entity.isEnabled,
            notificationIDs: entity.notificationIDs,
            createdAt: entity.createdAt
        )
    }
}
