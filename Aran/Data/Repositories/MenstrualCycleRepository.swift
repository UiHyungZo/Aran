import Foundation
import SwiftData
import AranDomain

@MainActor
final class MenstrualCycleRepository: MenstrualCycleRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [MenstrualCycle] {
        let descriptor = FetchDescriptor<MenstrualCycleModel>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try context.fetch(descriptor).map { MenstrualCycleMapper.toDomain($0) }
    }

    func fetch(date: Date) async throws -> MenstrualCycle? {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<MenstrualCycleModel>(
            predicate: #Predicate { $0.startDate >= start && $0.startDate < end }
        )
        return try context.fetch(descriptor).first.map { MenstrualCycleMapper.toDomain($0) }
    }

    func save(_ cycle: MenstrualCycle) async throws {
        context.insert(MenstrualCycleMapper.toModel(cycle))
        try context.save()
    }

    func update(_ cycle: MenstrualCycle) async throws {
        let id = cycle.id
        let descriptor = FetchDescriptor<MenstrualCycleModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        model.startDate = cycle.startDate
        model.cycleLength = cycle.cycleLength
        model.periodLength = cycle.periodLength
        try context.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<MenstrualCycleModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
