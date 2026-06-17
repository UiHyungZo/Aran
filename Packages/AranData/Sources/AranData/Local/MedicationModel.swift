import Foundation
import SwiftData
import AranDomain

@Model
public final class MedicationModel {
    @Attribute(.unique) public var id: UUID
    public var drugName: String
    public var dosage: String
    public var component: String = ""
    public var typeRawValue: String
    // Legacy field for existing stores. New writes mirror timeSlots into this field.
    public var scheduleTimes: [Date]
    @Relationship(deleteRule: .cascade, inverse: \MedicationTimeSlotModel.medication)
    public var timeSlots: [MedicationTimeSlotModel]
    public var scheduleStartDate: Date
    public var scheduleEndDate: Date?
    public var isEnabled: Bool
    public var notificationIDs: [String]
    public var createdAt: Date

    public init(
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
