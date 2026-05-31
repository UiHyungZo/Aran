@testable import Aran
import Foundation

final class MockDrugRepository: DrugRepositoryProtocol {
    var searchResult: DrugSearchResult = DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1)
    var searchKeywords: [String] = []
    var shouldThrow: Error?

    func search(keyword: String, pageNo _: Int) async throws -> DrugSearchResult {
        if let error = shouldThrow { throw error }
        searchKeywords.append(keyword)
        return searchResult
    }
}
