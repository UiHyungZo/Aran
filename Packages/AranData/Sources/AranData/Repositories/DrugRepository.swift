import Foundation
import AranDomain

public final class DrugRepository: DrugRepositoryProtocol {
    private let apiClient: any DrugAPIClientProtocol
    private let approvalAPIClient: (any DrugApprovalAPIClientProtocol)?
    private var currentSearchUseFallback = false

    public init(apiClient: any DrugAPIClientProtocol, approvalAPIClient: (any DrugApprovalAPIClientProtocol)? = nil) {
        self.apiClient = apiClient
        self.approvalAPIClient = approvalAPIClient
    }

    public convenience init(serviceKey: String, baseURL: String) {
        self.init(apiClient: DrugAPIClient(serviceKey: serviceKey, baseURL: baseURL))
    }

    public convenience init(
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
    /// page 1에서 결정된 API 소스를 이후 페이지에도 일관되게 사용한다.
    public func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        guard let approvalAPIClient else {
            return try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
        }
        if pageNo == 1 {
            do {
                let primary = try await approvalAPIClient.searchDrugs(itemName: keyword, pageNo: pageNo)
                if !primary.drugs.isEmpty {
                    currentSearchUseFallback = false
                    return primary
                }
            } catch {}
            let fallback = try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
            currentSearchUseFallback = true
            return fallback
        } else {
            if currentSearchUseFallback {
                return try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
            } else {
                return try await approvalAPIClient.searchDrugs(itemName: keyword, pageNo: pageNo)
            }
        }
    }

    public func enrich(_ drug: Drug) async throws -> Drug {
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
