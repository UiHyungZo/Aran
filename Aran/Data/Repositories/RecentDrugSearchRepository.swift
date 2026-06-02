import Foundation
import SwiftData

final class RecentDrugSearchRepository: RecentDrugSearchRepositoryProtocol {
    private let context: ModelContext
    private let maxCount = 10

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [RecentDrugSearch] {
        let descriptor = FetchDescriptor<RecentDrugSearchModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { RecentDrugSearchMapper.toDomain($0) }
    }

    func save(keyword: String) async throws {
        if let existing = try fetchModel(keyword: keyword) {
            existing.createdAt = Date()
        } else {
            context.insert(RecentDrugSearchModel(keyword: keyword))
        }
        try trimOverflow()
        try context.save()
    }

    func delete(keyword: String) async throws {
        if let model = try fetchModel(keyword: keyword) {
            context.delete(model)
            try context.save()
        }
    }

    func clear() async throws {
        let models = try context.fetch(FetchDescriptor<RecentDrugSearchModel>())
        for model in models {
            context.delete(model)
        }
        try context.save()
    }

    private func fetchModel(keyword: String) throws -> RecentDrugSearchModel? {
        let descriptor = FetchDescriptor<RecentDrugSearchModel>(
            predicate: #Predicate { $0.keyword == keyword }
        )
        return try context.fetch(descriptor).first
    }

    private func trimOverflow() throws {
        let descriptor = FetchDescriptor<RecentDrugSearchModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        for model in models.dropFirst(maxCount) {
            context.delete(model)
        }
    }
}
