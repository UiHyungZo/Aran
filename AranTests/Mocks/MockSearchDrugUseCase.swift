@testable import Aran
import Foundation

final class MockSearchDrugUseCase: SearchDrugUseCaseProtocol {
    var stubbedDrugs: [Drug] = []
    var stubbedDetail: Drug?
    var shouldThrow: Error?

    func execute(keyword: String, pageNo: Int) async throws -> [Drug] {
        if let error = shouldThrow { throw error }
        return stubbedDrugs
    }

    func detail(itemSeq: String) async throws -> Drug {
        if let error = shouldThrow { throw error }
        guard let drug = stubbedDetail else {
            throw AppError.networkError(URLError(.badServerResponse))
        }
        return drug
    }
}
