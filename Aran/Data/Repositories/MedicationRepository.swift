import Foundation
import SwiftData
import AranDomain

final class MedicationRepository: MedicationRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [Medication] {
        let descriptor = FetchDescriptor<MedicationModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { MedicationMapper.toDomain($0) }
    }

    func save(_ medication: Medication) async throws {
        let model = MedicationMapper.toModel(medication)
        for slot in model.timeSlots {
            slot.medication = model
        }
        context.insert(model)
        try context.save()
    }

    func update(_ medication: Medication) async throws {
        let id = medication.id
        let descriptor = FetchDescriptor<MedicationModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        model.drugName = medication.drugName
        model.dosage = medication.dosage
        model.component = medication.component
        model.typeRawValue = medication.type.rawValue
        model.scheduleTimes = medication.schedule.timeSlots.map(\.time)
        model.scheduleStartDate = medication.schedule.startDate
        model.scheduleEndDate = medication.schedule.endDate
        model.isEnabled = medication.isEnabled
        model.notificationIDs = medication.notificationIDs
        model.timeSlots.removeAll()
        for slot in medication.schedule.timeSlots {
            let slotModel = MedicationTimeSlotModel(
                id: slot.id,
                time: slot.time,
                isEnabled: slot.isEnabled,
                medication: model
            )
            model.timeSlots.append(slotModel)
        }
        try context.save()
    }

    func addTimeSlot(_ slot: MedicationTimeSlot, to medicationId: UUID) async throws {
        let descriptor = FetchDescriptor<MedicationModel>(
            predicate: #Predicate { $0.id == medicationId }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        let slotModel = MedicationTimeSlotModel(
            id: slot.id,
            time: slot.time,
            isEnabled: slot.isEnabled,
            medication: model
        )
        model.timeSlots.append(slotModel)
        model.scheduleTimes = model.timeSlots.map(\.time)
        model.isEnabled = model.timeSlots.contains(where: \.isEnabled)
        try context.save()
    }

    func removeTimeSlot(_ slotId: UUID, from medicationId: UUID) async throws {
        let descriptor = FetchDescriptor<MedicationModel>(
            predicate: #Predicate { $0.id == medicationId }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        guard let slot = model.timeSlots.first(where: { $0.id == slotId }) else { return }
        model.timeSlots.removeAll { $0.id == slotId }
        context.delete(slot)
        model.scheduleTimes = model.timeSlots.map(\.time)
        model.isEnabled = model.timeSlots.contains(where: \.isEnabled)
        try context.save()
    }

    func updateTimeSlot(_ slot: MedicationTimeSlot) async throws {
        let slotId = slot.id
        let descriptor = FetchDescriptor<MedicationTimeSlotModel>(
            predicate: #Predicate { $0.id == slotId }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        model.time = slot.time
        model.isEnabled = slot.isEnabled
        if let medication = model.medication {
            medication.scheduleTimes = medication.timeSlots.map(\.time)
            medication.isEnabled = medication.timeSlots.contains(where: \.isEnabled)
        }
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<MedicationModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            let logDescriptor = FetchDescriptor<MedicationLogModel>(
                predicate: #Predicate { $0.medicationId == id }
            )
            for log in try context.fetch(logDescriptor) {
                context.delete(log)
            }
            context.delete(model)
            try context.save()
        }
    }
}
