import Foundation
import SwiftData

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
        model.typeRawValue = medication.type.rawValue
        model.scheduleTimes = medication.schedule.times
        model.scheduleStartDate = medication.schedule.startDate
        model.scheduleEndDate = medication.schedule.endDate
        model.isEnabled = medication.isEnabled
        model.notificationIDs = medication.notificationIDs
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<MedicationModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
