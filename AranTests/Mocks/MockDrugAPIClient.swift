@testable import Aran
import Foundation

final class MockDrugAPIClient: DrugAPIClientProtocol {
    var searchResult: Result<DrugSearchResult, Error> = .success(DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1))
    private(set) var searchCallCount = 0
    private(set) var receivedKeyword: String?

    func searchDrugs(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        searchCallCount += 1
        receivedKeyword = keyword
        return try searchResult.get()
    }
}
