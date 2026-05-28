import Foundation
import SwiftData

@MainActor
final class MedicationLogRepository: MedicationLogRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [MedicationLog] {
        let descriptor = FetchDescriptor<MedicationLogModel>(
            sortBy: [SortDescriptor(\.logDate, order: .reverse)]
        )
        return try context.fetch(descriptor).map { MedicationLogMapper.toDomain($0) }
    }

    func fetch(date: Date) async throws -> [MedicationLog] {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<MedicationLogModel>(
            predicate: #Predicate { $0.logDate >= start && $0.logDate < end }
        )
        return try context.fetch(descriptor).map { MedicationLogMapper.toDomain($0) }
    }

    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog? {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<MedicationLogModel>(
            predicate: #Predicate {
                $0.medicationId == medicationId && $0.logDate >= start && $0.logDate < end
            }
        )
        return try context.fetch(descriptor).first.map { MedicationLogMapper.toDomain($0) }
    }

    func fetch(medicationId: UUID, date: Date, timeSlotID: UUID) async throws -> MedicationLog? {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<MedicationLogModel>(
            predicate: #Predicate {
                $0.medicationId == medicationId && $0.logDate >= start && $0.logDate < end
            }
        )
        return try context.fetch(descriptor)
            .first {
                ($0.timeSlotID ?? MedicationLegacySlotID.make(
                    medicationID: $0.medicationId,
                    index: $0.timeIndex
                )) == timeSlotID
            }
            .map { MedicationLogMapper.toDomain($0) }
    }

    func upsert(_ log: MedicationLog) async throws {
        let medicationId = log.medicationId
        let start = Calendar.current.startOfDay(for: log.logDate)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<MedicationLogModel>(
            predicate: #Predicate {
                $0.medicationId == medicationId && $0.logDate >= start && $0.logDate < end
            }
        )
        let models = try context.fetch(descriptor)
        if let model = models.first(where: {
            ($0.timeSlotID ?? MedicationLegacySlotID.make(
                medicationID: $0.medicationId,
                index: $0.timeIndex
            )) == log.timeSlotID
        }) {
            model.logDate = start
            model.isTaken = log.isTaken
            model.timeSlotID = log.timeSlotID
        } else {
            context.insert(MedicationLogModel(
                id: log.id,
                medicationId: medicationId,
                logDate: start,
                isTaken: log.isTaken,
                timeSlotID: log.timeSlotID
            ))
        }
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<MedicationLogModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }

    func deleteLogs(for medicationId: UUID) async throws {
        let descriptor = FetchDescriptor<MedicationLogModel>(
            predicate: #Predicate { $0.medicationId == medicationId }
        )
        for model in try context.fetch(descriptor) {
            context.delete(model)
        }
        try context.save()
    }
}
