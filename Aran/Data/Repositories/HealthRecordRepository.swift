import Foundation
import SwiftData

final class HealthRecordRepository: HealthRecordRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [HealthRecord] {
        let descriptor = FetchDescriptor<HealthRecordModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { HealthRecordMapper.toDomain($0) }
    }

    func fetch(item: TestItem) async throws -> [HealthRecord] {
        let rawValue = item.rawValue
        let descriptor = FetchDescriptor<HealthRecordModel>(
            predicate: #Predicate { $0.testItemRawValue == rawValue },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { HealthRecordMapper.toDomain($0) }
    }

    func save(_ record: HealthRecord) async throws {
        let model = HealthRecordMapper.toModel(record)
        context.insert(model)
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
