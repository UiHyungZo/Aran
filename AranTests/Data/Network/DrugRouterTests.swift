@testable import Aran
import XCTest

final class DrugRouterTests: XCTestCase {
    private let testServiceKey = "test-key"
    private let testBaseURL = "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService"

    func test_searchRouter_whenKeywordProvided_thenURLContainsKeyword() throws {
        // given
        let router = DrugRouter.search(
            keyword: "프로게스테론",
            pageNo: 1,
            serviceKey: testServiceKey,
            baseURL: testBaseURL
        )

        // when
        let request = try router.asURLRequest()

        // then
        let urlString = request.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("itemName"), "URL must contain itemName parameter")
        XCTAssertTrue(
            urlString.contains("%ED%94%84%EB%A1%9C%EA%B2%8C%EC%8A%A4%ED%85%8C%EB%A1%A0") ||
            urlString.contains("프로게스테론"),
            "URL must contain encoded keyword"
        )
    }

    func test_searchRouter_whenBuilt_thenHTTPMethodIsGET() throws {
        // given
        let router = DrugRouter.search(
            keyword: "테스트",
            pageNo: 1,
            serviceKey: testServiceKey,
            baseURL: testBaseURL
        )

        // when
        let request = try router.asURLRequest()

        // then
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func test_searchRouter_whenBuilt_thenContainsRequiredParameters() throws {
        // given
        let router = DrugRouter.search(
            keyword: "테스트",
            pageNo: 2,
            serviceKey: testServiceKey,
            baseURL: testBaseURL
        )

        // when
        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""

        // then
        XCTAssertTrue(urlString.contains("pageNo=2"), "URL must contain pageNo")
        XCTAssertTrue(urlString.contains("type=json"), "URL must contain type=json")
        XCTAssertTrue(urlString.contains("numOfRows"), "URL must contain numOfRows")
    }

    func test_searchRouter_whenBuilt_thenBaseURLIsCorrect() throws {
        // given
        let router = DrugRouter.search(
            keyword: "테스트",
            pageNo: 1,
            serviceKey: testServiceKey,
            baseURL: testBaseURL
        )

        // when
        let request = try router.asURLRequest()

        // then
        XCTAssertEqual(request.url?.host, "apis.data.go.kr")
        XCTAssertTrue(request.url?.path.contains("DrbEasyDrugInfoService") == true)
    }
}
