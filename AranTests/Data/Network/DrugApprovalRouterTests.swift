import XCTest
@testable import Aran

final class DrugApprovalRouterTests: XCTestCase {
    func test_search_buildsExpectedURLRequest() {
        let request = try? DrugApprovalRouter.search(
            itemName: "타이레놀",
            pageNo: 2,
            serviceKey: "TEST_KEY",
            baseURL: "https://example.com"
        ).asURLRequest()

        XCTAssertNotNil(request)
        let url = request?.url?.absoluteString ?? ""
        XCTAssertTrue(url.contains("/getDrugPrdtPrmsnInq07"))
        XCTAssertTrue(url.contains("item_name=%ED%83%80%EC%9D%B4%EB%A0%88%EB%86%80"))
        XCTAssertTrue(url.contains("serviceKey=TEST_KEY"))
        XCTAssertTrue(url.contains("pageNo=2"))
    }

    func test_detail_buildsExpectedURLRequest() {
        let request = try? DrugApprovalRouter.detail(
            itemSeq: "195700004",
            serviceKey: "TEST_KEY",
            baseURL: "https://example.com"
        ).asURLRequest()

        XCTAssertNotNil(request)
        let url = request?.url?.absoluteString ?? ""
        XCTAssertTrue(url.contains("/getDrugPrdtPrmsnDtlInq06"))
        XCTAssertTrue(url.contains("item_seq=195700004"))
        XCTAssertTrue(url.contains("serviceKey=TEST_KEY"))
        XCTAssertTrue(url.contains("pageNo=1"))
        XCTAssertTrue(url.contains("numOfRows=1"))
    }
}
