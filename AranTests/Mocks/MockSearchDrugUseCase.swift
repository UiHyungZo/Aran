@testable import Aran
import Foundation

final class MockSearchDrugUseCase: SearchDrugUseCaseProtocol {
    var stubbedResult: DrugSearchResult = DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1)
    var shouldThrow: Error?

    func execute(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        if let error = shouldThrow { throw error }
        return stubbedResult
    }
}
