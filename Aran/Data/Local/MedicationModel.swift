import Foundation
import SwiftData

@Model
final class MedicationModel {
    @Attribute(.unique) var id: UUID
    var drugName: String
    var dosage: String
    var typeRawValue: String
    var scheduleTimes: [Date]
    var scheduleStartDate: Date
    var scheduleEndDate: Date?
    var isEnabled: Bool
    var notificationIDs: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        drugName: String,
        dosage: String,
        typeRawValue: String,
        scheduleTimes: [Date],
        scheduleStartDate: Date,
        scheduleEndDate: Date? = nil,
        isEnabled: Bool = true,
        notificationIDs: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.drugName = drugName
        self.dosage = dosage
        self.typeRawValue = typeRawValue
        self.scheduleTimes = scheduleTimes
        self.scheduleStartDate = scheduleStartDate
        self.scheduleEndDate = scheduleEndDate
        self.isEnabled = isEnabled
        self.notificationIDs = notificationIDs
        self.createdAt = createdAt
    }
}
