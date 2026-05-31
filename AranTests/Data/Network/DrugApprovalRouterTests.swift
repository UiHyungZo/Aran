@testable import Aran
import XCTest

final class DrugApprovalRouterTests: XCTestCase {
    private let testServiceKey = "test-key"
    private let testBaseURL = "https://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService07"

    func test_searchRouter_whenBuilt_thenContainsRequiredParameters() throws {
        let router = DrugApprovalRouter.search(
            itemName: "소론도정",
            serviceKey: testServiceKey,
            baseURL: testBaseURL
        )

        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""

        XCTAssertTrue(urlString.contains("item_name"))
        XCTAssertTrue(urlString.contains("type=json"))
        XCTAssertTrue(urlString.contains("pageNo=1"))
        XCTAssertTrue(urlString.contains("numOfRows=20"))
    }

    func test_searchRouter_whenBuilt_thenUsesProductApprovalEndpoint() throws {
        let router = DrugApprovalRouter.search(
            itemName: "소론도정",
            serviceKey: testServiceKey,
            baseURL: testBaseURL
        )

        let request = try router.asURLRequest()

        XCTAssertEqual(request.url?.host, "apis.data.go.kr")
        XCTAssertTrue(request.url?.path.contains("DrugPrdtPrmsnInfoService07") == true)
        XCTAssertTrue(request.url?.path.contains("getDrugPrdtPrmsnInq07") == true)
    }
}
