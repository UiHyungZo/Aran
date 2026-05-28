import Foundation

enum DrugRouter {
    case search(keyword: String, pageNo: Int, serviceKey: String, baseURL: String)
    case detail(itemSeq: String, serviceKey: String, baseURL: String)

    private var path: String {
        switch self {
        case .search: return "/getDrbEasyDrugList"
        case .detail: return "/getDrbEasyDrugList"
        }
    }

    private var baseURLString: String {
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

    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURLString + path) else {
            throw AppError.invalidInput("Invalid URL")
        }
        var queryItems = [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "type", value: "json"),
        ]
        switch self {
        case let .search(keyword, pageNo, _, _):
            queryItems += [
                URLQueryItem(name: "itemName", value: keyword),
                URLQueryItem(name: "pageNo", value: "\(pageNo)"),
                URLQueryItem(name: "numOfRows", value: "20"),
            ]
        case let .detail(itemSeq, _, _):
            queryItems.append(URLQueryItem(name: "itemSeq", value: itemSeq))
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw AppError.invalidInput("Invalid URL components")
        }
        return URLRequest(url: url)
    }
}
