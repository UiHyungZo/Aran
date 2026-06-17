import Foundation
import SwiftData
import AranDomain

@Model
public final class MedicationLogModel {
    @Attribute(.unique) public var id: UUID
    public var medicationId: UUID
    public var logDate: Date
    public var isTaken: Bool
    public var timeSlotID: UUID?
    // Legacy field for existing stores.
    public var timeIndex: Int = 0

    public init(
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
