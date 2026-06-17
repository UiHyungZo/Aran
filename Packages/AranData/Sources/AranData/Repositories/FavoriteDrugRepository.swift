import Foundation
import SwiftData
import AranDomain

public final class FavoriteDrugRepository: FavoriteDrugRepositoryProtocol {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func fetchAll() async throws -> [FavoriteDrug] {
        let descriptor = FetchDescriptor<FavoriteDrugModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { FavoriteDrugMapper.toDomain($0) }
    }

    public func save(_ favoriteDrug: FavoriteDrug) async throws {
        if let existing = try fetchModel(itemSeq: favoriteDrug.itemSeq) {
            update(existing, with: favoriteDrug)
        } else {
            context.insert(FavoriteDrugMapper.toModel(favoriteDrug))
        }
        try context.save()
    }

    public func delete(itemSeq: String) async throws {
        if let model = try fetchModel(itemSeq: itemSeq) {
            context.delete(model)
            try context.save()
        }
    }

    public func exists(itemSeq: String) async throws -> Bool {
        try fetchModel(itemSeq: itemSeq) != nil
    }

    private func fetchModel(itemSeq: String) throws -> FavoriteDrugModel? {
        let descriptor = FetchDescriptor<FavoriteDrugModel>(
            predicate: #Predicate { $0.itemSeq == itemSeq }
        )
        return try context.fetch(descriptor).first
    }

    private func update(_ model: FavoriteDrugModel, with favoriteDrug: FavoriteDrug) {
        // id, createdAt은 기존 레코드 값을 유지한다 (즐겨찾기 정렬 순서 보존)
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
    }
}
