import Alamofire
import Foundation

final class DrugApprovalAPIClient: DrugApprovalAPIClientProtocol {
    private let session: Session
    private let serviceKey: String
    private let baseURL: String

    init(serviceKey: String, baseURL: String, session: Session = .default) {
        self.serviceKey = serviceKey
        self.baseURL = baseURL
        self.session = session
    }

    func searchDrugs(itemName: String, pageNo: Int) async throws -> DrugSearchResult {
        let response = try await fetchResponse(itemName: itemName, pageNo: pageNo)
        let drugs = response.body.items?.map { $0.toDrug() } ?? []
        return DrugSearchResult(
            drugs: drugs,
            totalCount: response.body.totalCount ?? drugs.count,
            pageNo: response.body.pageNo ?? pageNo
        )
    }

    func fetchApprovalInfo(itemName: String) async throws -> [DrugApprovalInfo] {
        let response = try await fetchResponse(itemName: itemName, pageNo: 1)
        return response.body.items?.map { $0.toDomain() } ?? []
    }

    private func fetchResponse(itemName: String, pageNo: Int) async throws -> DrugApprovalResponseDTO {
        try await session
            .request(try DrugApprovalRouter.search(itemName: itemName, pageNo: pageNo, serviceKey: serviceKey, baseURL: baseURL).asURLRequest())
            .serializingDecodable(DrugApprovalResponseDTO.self)
            .value
    }
}
