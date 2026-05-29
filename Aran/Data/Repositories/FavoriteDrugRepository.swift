import Foundation
import SwiftData

final class FavoriteDrugRepository: FavoriteDrugRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [FavoriteDrug] {
        let descriptor = FetchDescriptor<FavoriteDrugModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { FavoriteDrugMapper.toDomain($0) }
    }

    func save(_ favoriteDrug: FavoriteDrug) async throws {
        if let existing = try fetchModel(itemSeq: favoriteDrug.itemSeq) {
            update(existing, with: favoriteDrug)
        } else {
            context.insert(FavoriteDrugMapper.toModel(favoriteDrug))
        }
        try context.save()
    }

    func delete(itemSeq: String) async throws {
        if let model = try fetchModel(itemSeq: itemSeq) {
            context.delete(model)
            try context.save()
        }
    }

    func exists(itemSeq: String) async throws -> Bool {
        try fetchModel(itemSeq: itemSeq) != nil
    }

    private func fetchModel(itemSeq: String) throws -> FavoriteDrugModel? {
        let descriptor = FetchDescriptor<FavoriteDrugModel>(
            predicate: #Predicate { $0.itemSeq == itemSeq }
        )
        return try context.fetch(descriptor).first
    }

    private func update(_ model: FavoriteDrugModel, with favoriteDrug: FavoriteDrug) {
        model.id = favoriteDrug.id
        model.itemName = favoriteDrug.itemName
        model.entpName = favoriteDrug.entpName
        model.component = favoriteDrug.component
        model.efcyQesitm = favoriteDrug.efcyQesitm
        model.useMethodQesitm = favoriteDrug.useMethodQesitm
        model.atpnWarnQesitm = favoriteDrug.atpnWarnQesitm
        model.atpnQesitm = favoriteDrug.atpnQesitm
        model.intrcQesitm = favoriteDrug.intrcQesitm
        model.seQesitm = favoriteDrug.seQesitm
        model.depositMethodQesitm = favoriteDrug.depositMethodQesitm
        model.itemImage = favoriteDrug.itemImage
        model.createdAt = favoriteDrug.createdAt
    }
}
