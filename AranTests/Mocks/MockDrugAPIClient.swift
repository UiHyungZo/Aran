@testable import Aran
import Foundation

final class MockDrugAPIClient: DrugAPIClientProtocol {
    var searchResult: Result<DrugSearchResult, Error> = .success(DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1))
    private(set) var searchCallCount = 0
    private(set) var receivedKeyword: String?

    var detailResult: Result<Drug, Error> = .success(Drug(
        itemSeq: "", itemName: "", entpName: "",
        efcyQesitm: nil, useMethodQesitm: nil, atpnWarnQesitm: nil,
        atpnQesitm: nil, intrcQesitm: nil, seQesitm: nil,
        depositMethodQesitm: nil, itemImage: nil
    ))

    func searchDrugs(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        searchCallCount += 1
        receivedKeyword = keyword
        return try searchResult.get()
    }

    func fetchDrugDetail(itemSeq: String) async throws -> Drug {
        return try detailResult.get()
    }
}
