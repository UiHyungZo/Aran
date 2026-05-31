import Foundation

final class DrugRepository: DrugRepositoryProtocol {
    private let apiClient: any DrugAPIClientProtocol

    init(apiClient: any DrugAPIClientProtocol) {
        self.apiClient = apiClient
    }

    convenience init(serviceKey: String, baseURL: String) {
        self.init(apiClient: DrugAPIClient(serviceKey: serviceKey, baseURL: baseURL))
    }

    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        do {
            return try await apiClient.searchDrugs(keyword: keyword, pageNo: pageNo)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error)
        }
    }
}
