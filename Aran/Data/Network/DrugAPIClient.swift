import Foundation
import Alamofire

final class DrugAPIClient {
    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func searchDrugs(keyword: String, pageNo: Int) async throws -> [Drug] {
        let response = try await session.request(DrugRouter.search(keyword: keyword, pageNo: pageNo))
            .serializingDecodable(DrugListResponseDTO.self)
            .value
        return response.body.items?.map { $0.toDomain() } ?? []
    }

    func fetchDrugDetail(itemSeq: String) async throws -> Drug {
        let response = try await session.request(DrugRouter.detail(itemSeq: itemSeq))
            .serializingDecodable(DrugDetailResponseDTO.self)
            .value
        guard let item = response.body.items?.first else {
            throw AppError.emptyResult
        }
        return item.toDomain()
    }
}
