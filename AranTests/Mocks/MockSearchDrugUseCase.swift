@testable import Aran
import Foundation

final class MockSearchDrugUseCase: SearchDrugUseCaseProtocol {
    var stubbedResult: DrugSearchResult = DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1)
    var stubbedDetail: Drug?
    var shouldThrow: Error?

    func execute(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        if let error = shouldThrow { throw error }
        return stubbedResult
    }

    func detail(itemSeq: String) async throws -> Drug {
        if let error = shouldThrow { throw error }
        guard let drug = stubbedDetail else {
            throw AppError.networkError(URLError(.badServerResponse))
        }
        return drug
    }
}
