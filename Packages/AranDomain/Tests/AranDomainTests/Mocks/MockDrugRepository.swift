import Foundation
import AranDomain

final class MockDrugRepository: DrugRepositoryProtocol {
    var searchResult: DrugSearchResult = DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1)
    var enrichedDrug: Drug?
    var searchKeywords: [String] = []
    var shouldThrow: Error?

    func search(keyword: String, pageNo _: Int) async throws -> DrugSearchResult {
        if let error = shouldThrow { throw error }
        searchKeywords.append(keyword)
        return searchResult
    }

    func enrich(_ drug: Drug) async throws -> Drug {
        if let error = shouldThrow { throw error }
        return enrichedDrug ?? drug
    }
}
