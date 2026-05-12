import Foundation
import Alamofire

enum DrugRouter: URLRequestConvertible {
    case search(keyword: String, pageNo: Int)
    case detail(itemSeq: String)

    private static let baseURL = "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService"
    private static let serviceKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "MFDS_SERVICE_KEY") as? String ?? ""
    }()

    private var path: String {
        switch self {
        case .search: return "/getDrbEasyDrugList"
        case .detail: return "/getDrbEasyDrugInfo"
        }
    }

    private var parameters: Parameters {
        var params: Parameters = [
            "serviceKey": Self.serviceKey,
            "type": "json"
        ]
        switch self {
        case let .search(keyword, pageNo):
            params["itemName"] = keyword
            params["pageNo"] = pageNo
            params["numOfRows"] = 20
        case let .detail(itemSeq):
            params["itemSeq"] = itemSeq
        }
        return params
    }

    func asURLRequest() throws -> URLRequest {
        let url = try (Self.baseURL + path).asURL()
        return try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
    }
}
