import Foundation
import SwiftData

@MainActor
final class HealthRecordRepository: HealthRecordRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [HealthRecord] {
        let descriptor = FetchDescriptor<HealthRecordModel>(
            sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
        )
        return try context.fetch(descriptor).map { HealthRecordMapper.toDomain($0) }
    }

    func fetch(type: String) async throws -> [HealthRecord] {
        let descriptor = FetchDescriptor<HealthRecordModel>(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
        )
        return try context.fetch(descriptor).map { HealthRecordMapper.toDomain($0) }
    }

    func save(_ record: HealthRecord) async throws {
        let model = HealthRecordMapper.toModel(record)
        context.insert(model)
        try context.save()
    }

    func update(_ record: HealthRecord) async throws {
        let id = record.id
        let descriptor = FetchDescriptor<HealthRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            model.type = record.type
            model.value = record.value
            model.unit = record.unit
            model.recordDate = record.recordDate
            model.memo = record.memo
        } else {
            context.insert(HealthRecordMapper.toModel(record))
        }
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<HealthRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
