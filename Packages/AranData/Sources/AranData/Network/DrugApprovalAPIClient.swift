import Alamofire
import Foundation
import AranDomain

public final class DrugApprovalAPIClient: DrugApprovalAPIClientProtocol {
    private let session: Session
    private let serviceKey: String
    private let baseURL: String

    public init(serviceKey: String, baseURL: String, session: Session = .default) {
        self.serviceKey = serviceKey
        self.baseURL = baseURL
        self.session = session
    }

    public func searchDrugs(itemName: String, pageNo: Int) async throws -> DrugSearchResult {
        let response = try await fetchResponse(itemName: itemName, pageNo: pageNo)
        let drugs = response.body.items?.map { $0.toDrug() } ?? []
        return DrugSearchResult(
            drugs: drugs,
            totalCount: response.body.totalCount ?? drugs.count,
            pageNo: response.body.pageNo ?? pageNo
        )
    }

    public func fetchDetail(itemSeq: String) async throws -> Drug? {
        let response = try await session
            .request(try DrugApprovalRouter.detail(itemSeq: itemSeq, serviceKey: serviceKey, baseURL: baseURL).asURLRequest())
            .serializingDecodable(DrugApprovalResponseDTO.self)
            .value
        return response.body.items?.first?.toDrug()
    }

    private func fetchResponse(itemName: String, pageNo: Int) async throws -> DrugApprovalResponseDTO {
        try await session
            .request(try DrugApprovalRouter.search(itemName: itemName, pageNo: pageNo, serviceKey: serviceKey, baseURL: baseURL).asURLRequest())
            .serializingDecodable(DrugApprovalResponseDTO.self)
            .value
    }
}
