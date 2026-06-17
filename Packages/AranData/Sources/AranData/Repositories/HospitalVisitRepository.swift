import Foundation
import SwiftData
import AranDomain

@MainActor
public final class HospitalVisitRepository: HospitalVisitRepositoryProtocol {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func fetchAll() async throws -> [HospitalVisit] {
        let descriptor = FetchDescriptor<HospitalVisitModel>(
            sortBy: [SortDescriptor(\.visitDate, order: .reverse)]
        )
        return try context.fetch(descriptor).map { HospitalVisitMapper.toDomain($0) }
    }

    public func fetch(date: Date) async throws -> [HospitalVisit] {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<HospitalVisitModel>(
            predicate: #Predicate { $0.visitDate >= start && $0.visitDate < end },
            sortBy: [SortDescriptor(\.visitDate)]
        )
        return try context.fetch(descriptor).map { HospitalVisitMapper.toDomain($0) }
    }

    public func save(_ visit: HospitalVisit) async throws {
        context.insert(HospitalVisitMapper.toModel(visit))
        try context.save()
    }

    public func update(_ visit: HospitalVisit) async throws {
        let id = visit.id
        let descriptor = FetchDescriptor<HospitalVisitModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        model.visitDate = visit.visitDate
        model.visitTypes = visit.visitTypes
        model.memo = visit.memo
        try context.save()
    }

    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<HospitalVisitModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
        }
    }
}
