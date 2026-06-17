@testable import Aran
import Foundation
import AranDomain

final class MockRecentDrugSearchRepository: RecentDrugSearchRepositoryProtocol {
    var searches: [RecentDrugSearch] = []
    var savedKeywords: [String] = []
    var deletedKeywords: [String] = []
    var clearCallCount = 0

    func fetchAll() async throws -> [RecentDrugSearch] {
        searches.sorted { $0.createdAt > $1.createdAt }
    }

    func save(keyword: String) async throws {
        savedKeywords.append(keyword)
        searches.removeAll { $0.keyword == keyword }
        searches.insert(RecentDrugSearch(keyword: keyword), at: 0)
    }

    func delete(keyword: String) async throws {
        deletedKeywords.append(keyword)
        searches.removeAll { $0.keyword == keyword }
    }

    func clear() async throws {
        clearCallCount += 1
        searches = []
    }
}
