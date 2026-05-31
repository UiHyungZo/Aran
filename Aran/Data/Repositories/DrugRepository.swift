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

    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        do {
            let result = try await apiClient.searchDrugs(keyword: keyword, pageNo: pageNo)
            guard result.drugs.isEmpty && pageNo == 1,
                  let approvalAPIClient else {
                return result
            }
            do {
                let approvalDrugs = try await approvalAPIClient.fetchApprovalInfo(itemName: keyword)
                    .map(\.drug)
                    .filter { !$0.itemSeq.isEmpty && !$0.itemName.isEmpty }
                    .deduplicatedByItemSeq()
                return approvalDrugs.isEmpty
                    ? result
                    : DrugSearchResult(drugs: approvalDrugs, totalCount: approvalDrugs.count, pageNo: pageNo)
            } catch {
                return result
            }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error)
        }
    }

    func enrich(_ drug: Drug) async throws -> Drug {
        guard let approvalAPIClient else { return drug }
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
}

private extension Array where Element == Drug {
    func deduplicatedByItemSeq() -> [Drug] {
        reduce(into: [Drug]()) { acc, drug in
            if !acc.contains(where: { $0.itemSeq == drug.itemSeq }) {
                acc.append(drug)
            }
        }
    }
}
