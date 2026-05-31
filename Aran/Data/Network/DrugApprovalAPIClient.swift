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

    func fetchApprovalInfo(itemName: String) async throws -> [DrugApprovalInfo] {
        let response = try await session
            .request(try DrugApprovalRouter.search(itemName: itemName, serviceKey: serviceKey, baseURL: baseURL).asURLRequest())
            .serializingDecodable(DrugApprovalResponseDTO.self)
            .value
        return response.body.items?.map { $0.toDomain() } ?? []
    }
}
