import Foundation
import AranDomain

final class MockSearchDrugUseCase: SearchDrugUseCaseProtocol {
    var stubbedResult: DrugSearchResult = DrugSearchResult(drugs: [], totalCount: 0, pageNo: 1)
    var stubbedEnrichedDrug: Drug?
    var shouldThrow: Error?
    private(set) var executeCallCount = 0
    private(set) var enrichCallCount = 0

    func execute(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        executeCallCount += 1
        if let error = shouldThrow { throw error }
        return stubbedResult
    }

    func enrich(_ drug: Drug) async throws -> Drug {
        enrichCallCount += 1
        if let error = shouldThrow { throw error }
        return stubbedEnrichedDrug ?? drug
    }
}
