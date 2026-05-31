import Foundation

enum DrugApprovalRouter {
    case search(itemName: String, pageNo: Int, serviceKey: String, baseURL: String)

    private var path: String {
        switch self {
        case .search: return "/getDrugPrdtPrmsnInq07"
        }
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

        var items = [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "type", value: "json"),
            URLQueryItem(name: "numOfRows", value: "20"),
        ]

        switch self {
        case let .search(itemName, pageNo, _, _):
            items.append(URLQueryItem(name: "pageNo", value: "\(pageNo)"))
            items.append(URLQueryItem(name: "item_name", value: itemName))
        }

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
