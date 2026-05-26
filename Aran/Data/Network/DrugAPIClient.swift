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

    func searchDrugs(keyword: String, pageNo: Int) async throws -> [Drug] {
        let response = try await session
            .request(DrugRouter.search(keyword: keyword, pageNo: pageNo, serviceKey: serviceKey, baseURL: baseURL))
            .serializingDecodable(DrugListResponseDTO.self)
            .value
        return response.body.items?.map { $0.toDomain() } ?? []
    }

    func fetchDrugDetail(itemSeq: String) async throws -> Drug {
        let response = try await session
            .request(DrugRouter.detail(itemSeq: itemSeq, serviceKey: serviceKey, baseURL: baseURL))
            .serializingDecodable(DrugListResponseDTO.self)
            .value
        guard let item = response.body.items?.first else {
            throw AppError.emptyResult
        }
        return item.toDomain()
    }
}
