import Foundation
import SwiftData
import AranDomain

@Model
final class MedicationLogModel {
    @Attribute(.unique) var id: UUID
    var medicationId: UUID
    var logDate: Date
    var isTaken: Bool
    var timeSlotID: UUID?
    // Legacy field for existing stores.
    var timeIndex: Int = 0

    init(
        id: UUID = UUID(),
        medicationId: UUID,
        logDate: Date,
        isTaken: Bool,
        timeSlotID: UUID? = nil,
        timeIndex: Int = 0
    ) {
        self.id = id
        self.medicationId = medicationId
        self.logDate = logDate
        self.isTaken = isTaken
        self.timeSlotID = timeSlotID
        self.timeIndex = timeIndex
    }
}
