import Foundation
import Alamofire

enum DrugRouter: URLRequestConvertible {
    case search(keyword: String, pageNo: Int, serviceKey: String, baseURL: String)
    case detail(itemSeq: String, serviceKey: String, baseURL: String)

    private var path: String {
        switch self {
        case .search: return "/getDrbEasyDrugList"
        case .detail: return "/getDrbEasyDrugInfo"
        }
    }

    private var baseURL: String {
        switch self {
        case let .search(_, _, _, url): return url
        case let .detail(_, _, url): return url
        }
    }

    private var serviceKey: String {
        switch self {
        case let .search(_, _, key, _): return key
        case let .detail(_, key, _): return key
        }
    }

    private var parameters: Parameters {
        var params: Parameters = [
            "serviceKey": serviceKey,
            "type": "json"
        ]
        switch self {
        case let .search(keyword, pageNo, _, _):
            params["itemName"] = keyword
            params["pageNo"] = pageNo
            params["numOfRows"] = 20
        case let .detail(itemSeq, _, _):
            params["itemSeq"] = itemSeq
        }
        return params
    }

    func asURLRequest() throws -> URLRequest {
        let url = try (baseURL + path).asURL()
        return try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
    }
}
