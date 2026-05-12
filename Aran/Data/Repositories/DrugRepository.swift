import Foundation

final class DrugRepository: DrugRepositoryProtocol {
    private let apiClient: DrugAPIClient

    init(apiClient: DrugAPIClient = DrugAPIClient()) {
        self.apiClient = apiClient
    }

    func search(keyword: String, pageNo: Int) async throws -> [Drug] {
        do {
            return try await apiClient.searchDrugs(keyword: keyword, pageNo: pageNo)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error)
        }
    }

    func detail(itemSeq: String) async throws -> Drug {
        do {
            return try await apiClient.fetchDrugDetail(itemSeq: itemSeq)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error)
        }
    }
}
