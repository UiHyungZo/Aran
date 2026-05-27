import Foundation
import SwiftData

@MainActor
final class PGTRecordRepository: PGTRecordRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [PGTRecord] {
        let descriptor = FetchDescriptor<PGTRecordModel>(
            sortBy: [SortDescriptor(\.testDate, order: .reverse)]
        )
        return try context.fetch(descriptor).map { PGTRecordMapper.toDomain($0) }
    }

    func fetch(cycleRecordId: UUID) async throws -> [PGTRecord] {
        let descriptor = FetchDescriptor<PGTRecordModel>(
            predicate: #Predicate { $0.cycleRecordId == cycleRecordId },
            sortBy: [SortDescriptor(\.testDate)]
        )
        return try context.fetch(descriptor).map { PGTRecordMapper.toDomain($0) }
    }

    func save(_ record: PGTRecord) async throws {
        let model = PGTRecordMapper.toModel(record)
        context.insert(model)
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<PGTRecordModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
