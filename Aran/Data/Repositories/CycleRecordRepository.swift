import Foundation
import SwiftData

final class CycleRecordRepository: CycleRecordRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [CycleRecord] {
        let descriptor = FetchDescriptor<CycleRecordModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { CycleRecordMapper.toDomain($0) }
    }

    func fetch(date: Date) async throws -> CycleRecord? {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let descriptor = FetchDescriptor<CycleRecordModel>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return try context.fetch(descriptor).first.map { CycleRecordMapper.toDomain($0) }
    }

    func save(_ record: CycleRecord) async throws {
        let model = CycleRecordMapper.toModel(record)
        context.insert(model)
        try context.save()
    }

    func update(_ record: CycleRecord) async throws {
        let id = record.id
        let descriptor = FetchDescriptor<CycleRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        let updated = CycleRecordMapper.toModel(record)
        model.eventsData = updated.eventsData
        model.diaryEmoji = updated.diaryEmoji
        model.diaryText = updated.diaryText
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<CycleRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
