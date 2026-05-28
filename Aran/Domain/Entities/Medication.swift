import Foundation

struct Medication: Identifiable {
    let id: UUID
    var drugName: String
    var dosage: String
    var component: String = ""
    var type: MedicationType
    var schedule: MedicationSchedule
    var isEnabled: Bool
    var notificationIDs: [String]
    var createdAt: Date
}

enum MedicationType: String, CaseIterable {
    case oral = "경구"
    case injection = "주사"
    case patch = "패치"
    case other = "기타"
}

struct MedicationSchedule {
    var timeSlots: [MedicationTimeSlot]
    var startDate: Date
    var endDate: Date?

    init(timeSlots: [MedicationTimeSlot], startDate: Date, endDate: Date?) {
        self.timeSlots = timeSlots
        self.startDate = startDate
        self.endDate = endDate
    }

    init(
        times: [Date],
        startDate: Date,
        endDate: Date?,
        medicationID: UUID = UUID(),
        isEnabled: Bool = true
    ) {
        self.timeSlots = times.enumerated().map { offset, time in
            MedicationTimeSlot(
                id: Self.legacySlotID(medicationID: medicationID, index: offset),
                time: time,
                isEnabled: isEnabled,
                medicationID: medicationID
            )
        }
        self.startDate = startDate
        self.endDate = endDate
    }

    var sortedTimeSlots: [MedicationTimeSlot] {
        timeSlots.sorted { lhs, rhs in
            let calendar = Calendar.current
            let lhsMinute = calendar.component(.hour, from: lhs.time) * 60 + calendar.component(.minute, from: lhs.time)
            let rhsMinute = calendar.component(.hour, from: rhs.time) * 60 + calendar.component(.minute, from: rhs.time)
            return lhsMinute < rhsMinute
        }
    }

    var times: [Date] {
        sortedTimeSlots.map(\.time)
    }

    private static func legacySlotID(medicationID: UUID, index: Int) -> UUID {
        let sanitized = medicationID.uuidString.replacingOccurrences(of: "-", with: "")
        let indexHex = String(format: "%08X", max(index, 0))
        let mergedHex = String(sanitized.prefix(24)) + indexHex
        let p1 = mergedHex.prefix(8)
        let p2 = mergedHex.dropFirst(8).prefix(4)
        let p3 = mergedHex.dropFirst(12).prefix(4)
        let p4 = mergedHex.dropFirst(16).prefix(4)
        let p5 = mergedHex.dropFirst(20).prefix(12)
        return UUID(uuidString: "\(p1)-\(p2)-\(p3)-\(p4)-\(p5)") ?? UUID()
    }
}
