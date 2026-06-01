import Alamofire
import Foundation

final class DrugAPIClient: DrugAPIClientProtocol {
    private let session: Session
    private let serviceKey: String
    private let baseURL: String

    init(serviceKey: String, baseURL: String, session: Session = .default) {
        self.serviceKey = serviceKey
        self.baseURL = baseURL
        self.session = session
    }

    func searchDrugs(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        let response = try await session
            .request(try DrugRouter.search(keyword: keyword, pageNo: pageNo, serviceKey: serviceKey, baseURL: baseURL).asURLRequest())
            .serializingDecodable(DrugListResponseDTO.self)
            .value
        let drugs = response.body.items?.map { $0.toDomain() } ?? []
        return DrugSearchResult(drugs: drugs, totalCount: response.body.totalCount, pageNo: response.body.pageNo)
    }

}
