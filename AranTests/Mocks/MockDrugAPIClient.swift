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

final class MockDrugApprovalAPIClient: DrugApprovalAPIClientProtocol {
    var approvalInfos: [DrugApprovalInfo] = []
    var shouldThrow: Error?
    private(set) var receivedItemName: String?

    func fetchApprovalInfo(itemName: String) async throws -> [DrugApprovalInfo] {
        if let error = shouldThrow { throw error }
        receivedItemName = itemName
        return approvalInfos
    }
}
