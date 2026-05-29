import Foundation

protocol FavoriteDrugRepositoryProtocol {
    func fetchAll() async throws -> [FavoriteDrug]
    func save(_ favoriteDrug: FavoriteDrug) async throws
    func delete(itemSeq: String) async throws
    func exists(itemSeq: String) async throws -> Bool
}
