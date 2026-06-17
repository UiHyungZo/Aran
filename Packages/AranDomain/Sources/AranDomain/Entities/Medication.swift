import Foundation

public struct Medication: Identifiable {
    public let id: UUID
    public var drugName: String
    public var dosage: String
    public var component: String
    public var type: MedicationType
    public var schedule: MedicationSchedule
    public var isEnabled: Bool
    public var notificationIDs: [String]
    public var createdAt: Date

    public init(
        id: UUID,
        drugName: String,
        dosage: String,
        component: String = "",
        type: MedicationType,
        schedule: MedicationSchedule,
        isEnabled: Bool,
        notificationIDs: [String],
        createdAt: Date
    ) {
        self.id = id
        self.drugName = drugName
        self.dosage = dosage
        self.component = component
        self.type = type
        self.schedule = schedule
        self.isEnabled = isEnabled
        self.notificationIDs = notificationIDs
        self.createdAt = createdAt
    }
}

public enum MedicationType: String, CaseIterable {
    case oral = "경구"
    case injection = "주사"
    case patch = "패치"
    case other = "기타"
}

public struct MedicationSchedule {
    public var timeSlots: [MedicationTimeSlot]
    public var startDate: Date
    public var endDate: Date?

    public init(timeSlots: [MedicationTimeSlot], startDate: Date, endDate: Date?) {
        self.timeSlots = timeSlots
        self.startDate = startDate
        self.endDate = endDate
    }

    public init(
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

    public var sortedTimeSlots: [MedicationTimeSlot] {
        timeSlots.sorted { lhs, rhs in
            let calendar = Calendar.current
            let lhsMinute = calendar.component(.hour, from: lhs.time) * 60 + calendar.component(.minute, from: lhs.time)
            let rhsMinute = calendar.component(.hour, from: rhs.time) * 60 + calendar.component(.minute, from: rhs.time)
            return lhsMinute < rhsMinute
        }
    }

    public var times: [Date] {
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
