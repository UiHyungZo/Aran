import Foundation
import SwiftData

@Model
final class MedicationLogModel {
    @Attribute(.unique) var id: UUID
    var medicationId: UUID
    var logDate: Date
    var isTaken: Bool
    var timeIndex: Int = 0

    init(id: UUID = UUID(), medicationId: UUID, logDate: Date, isTaken: Bool, timeIndex: Int = 0) {
        self.id = id
        self.medicationId = medicationId
        self.logDate = logDate
        self.isTaken = isTaken
        self.timeIndex = timeIndex
    }
}
