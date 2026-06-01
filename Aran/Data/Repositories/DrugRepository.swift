import Foundation

final class DrugRepository: DrugRepositoryProtocol {
    private let apiClient: any DrugAPIClientProtocol
    private let approvalAPIClient: (any DrugApprovalAPIClientProtocol)?

    init(apiClient: any DrugAPIClientProtocol, approvalAPIClient: (any DrugApprovalAPIClientProtocol)? = nil) {
        self.apiClient = apiClient
        self.approvalAPIClient = approvalAPIClient
    }

    convenience init(serviceKey: String, baseURL: String) {
        self.init(apiClient: DrugAPIClient(serviceKey: serviceKey, baseURL: baseURL))
    }

    convenience init(
        serviceKey: String,
        baseURL: String,
        approvalServiceKey: String,
        approvalBaseURL: String
    ) {
        self.init(
            apiClient: DrugAPIClient(serviceKey: serviceKey, baseURL: baseURL),
            approvalAPIClient: DrugApprovalAPIClient(serviceKey: approvalServiceKey, baseURL: approvalBaseURL)
        )
    }

    /// primary = 전문의약품(approvalAPIClient), fallback = e약은요(apiClient)
    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        guard let approvalAPIClient else {
            return try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
        }
        do {
            let primary = try await approvalAPIClient.searchDrugs(itemName: keyword, pageNo: pageNo)
            if !primary.drugs.isEmpty || pageNo != 1 {
                return primary
            }
            let fallback = try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
            return fallback.drugs.isEmpty ? primary : fallback
        } catch {
            return try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
        }
    }

    func enrich(_ drug: Drug) async throws -> Drug {
        guard let approvalAPIClient else { return drug }
        do {
            guard let detail = try await approvalAPIClient.fetchDetail(itemSeq: drug.itemSeq) else {
                return drug
            }
            return drug.merging(detail: detail)
        } catch {
            return drug
        }
    }

    private func searchEasyDrug(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        do {
            return try await apiClient.searchDrugs(keyword: keyword, pageNo: pageNo)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error)
        }
    }
}
