import Foundation

enum DrugRouter {
    case search(keyword: String, pageNo: Int, serviceKey: String, baseURL: String)

    private var path: String {
        "/getDrbEasyDrugList"
    }

    private var baseURLString: String {
        switch self {
        case let .search(_, _, _, url): return url
        }
    }

    private var serviceKey: String {
        switch self {
        case let .search(_, _, key, _): return key
        }
    }

    private static let queryValueAllowed: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "+&=/")
        return allowed
    }()

    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURLString + path) else {
            throw URLError(.badURL)
        }
        guard case let .search(keyword, pageNo, _, _) = self else {
            throw URLError(.badURL)
        }
        let items = [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "type", value: "json"),
            URLQueryItem(name: "itemName", value: keyword),
            URLQueryItem(name: "pageNo", value: "\(pageNo)"),
            URLQueryItem(name: "numOfRows", value: "20"),
        ]
        components.percentEncodedQueryItems = items.map {
            URLQueryItem(
                name: $0.name,
                value: $0.value?.addingPercentEncoding(withAllowedCharacters: Self.queryValueAllowed) ?? $0.value
            )
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return URLRequest(url: url)
    }
}
