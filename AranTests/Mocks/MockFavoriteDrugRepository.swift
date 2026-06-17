@testable import Aran
import Foundation
import AranDomain

final class MockFavoriteDrugRepository: FavoriteDrugRepositoryProtocol {
    var favoriteDrugs: [FavoriteDrug] = []
    var savedDrugs: [FavoriteDrug] = []
    var deletedItemSeqs: [String] = []

    func fetchAll() async throws -> [FavoriteDrug] {
        favoriteDrugs
    }

    func save(_ favoriteDrug: FavoriteDrug) async throws {
        savedDrugs.append(favoriteDrug)
        favoriteDrugs.removeAll { $0.itemSeq == favoriteDrug.itemSeq }
        favoriteDrugs.append(favoriteDrug)
    }

    func delete(itemSeq: String) async throws {
        deletedItemSeqs.append(itemSeq)
        favoriteDrugs.removeAll { $0.itemSeq == itemSeq }
    }

    func exists(itemSeq: String) async throws -> Bool {
        favoriteDrugs.contains { $0.itemSeq == itemSeq }
    }
}
