import Foundation
import SwiftData

@Model
final class MedicationModel {
    @Attribute(.unique) var id: UUID
    var drugName: String
    var dosage: String
    var component: String = ""
    var typeRawValue: String
    // Legacy field for existing stores. New writes mirror timeSlots into this field.
    var scheduleTimes: [Date]
    @Relationship(deleteRule: .cascade, inverse: \MedicationTimeSlotModel.medication)
    var timeSlots: [MedicationTimeSlotModel]
    var scheduleStartDate: Date
    var scheduleEndDate: Date?
    var isEnabled: Bool
    var notificationIDs: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        drugName: String,
        dosage: String,
        component: String = "",
        typeRawValue: String,
        scheduleTimes: [Date],
        timeSlots: [MedicationTimeSlotModel] = [],
        scheduleStartDate: Date,
        scheduleEndDate: Date? = nil,
        isEnabled: Bool = true,
        notificationIDs: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.drugName = drugName
        self.dosage = dosage
        self.component = component
        self.typeRawValue = typeRawValue
        self.scheduleTimes = scheduleTimes
        self.timeSlots = timeSlots
        self.scheduleStartDate = scheduleStartDate
        self.scheduleEndDate = scheduleEndDate
        self.isEnabled = isEnabled
        self.notificationIDs = notificationIDs
        self.createdAt = createdAt
    }
}
