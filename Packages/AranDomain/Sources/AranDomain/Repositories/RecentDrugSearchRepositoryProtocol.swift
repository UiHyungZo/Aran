import Foundation

public protocol RecentDrugSearchRepositoryProtocol {
    func fetchAll() async throws -> [RecentDrugSearch]
    func save(keyword: String) async throws
    func delete(keyword: String) async throws
    func clear() async throws
}
