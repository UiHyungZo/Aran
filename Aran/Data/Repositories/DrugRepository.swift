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

    /// primary = 전문의약품 상세(approvalAPIClient), fallback = e약은요(apiClient)
    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        guard let approvalAPIClient else {
            return try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
        }
        do {
            let primary = try await approvalAPIClient.searchDrugs(itemName: keyword, pageNo: pageNo)
            // 결과가 있거나 첫 페이지가 아니면 그대로 사용. 첫 페이지에서 비었을 때만 e약은요로 폴백.
            if !primary.drugs.isEmpty || pageNo != 1 {
                return primary
            }
            let fallback = try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
            return fallback.drugs.isEmpty ? primary : fallback
        } catch {
            // 전문의약품 API 실패 시 e약은요로 폴백
            return try await searchEasyDrug(keyword: keyword, pageNo: pageNo)
        }
    }

    func enrich(_ drug: Drug) async throws -> Drug {
        // primary 결과는 이미 approvalInfo 보유 → no-op. e약은요 fallback 결과만 보강한다.
        guard drug.approvalInfo == nil, let approvalAPIClient else { return drug }
        do {
            let approvalInfos = try await approvalAPIClient.fetchApprovalInfo(itemName: drug.itemName)
            guard let approvalInfo = approvalInfos.first(where: { $0.itemSeq == drug.itemSeq }) else {
                return drug
            }
            return drug.enriched(with: approvalInfo)
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
