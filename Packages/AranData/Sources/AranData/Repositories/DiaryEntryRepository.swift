import Foundation
import SwiftData
import AranDomain

@MainActor
public final class DiaryEntryRepository: DiaryEntryRepositoryProtocol {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func fetchAll() async throws -> [DiaryEntry] {
        let descriptor = FetchDescriptor<DiaryEntryModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { DiaryEntryMapper.toDomain($0) }
    }

    public func fetch(date: Date) async throws -> DiaryEntry? {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<DiaryEntryModel>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return try context.fetch(descriptor).first.map { DiaryEntryMapper.toDomain($0) }
    }

    public func save(_ diary: DiaryEntry) async throws {
        context.insert(DiaryEntryMapper.toModel(diary))
        try context.save()
    }

    public func update(_ diary: DiaryEntry) async throws {
        let id = diary.id
        let descriptor = FetchDescriptor<DiaryEntryModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        model.date = diary.date
        model.emoji = diary.emoji
        model.content = diary.content
        try context.save()
    }

    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<DiaryEntryModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
