@testable import Aran
import Alamofire
import XCTest

final class DrugAPIClientTests: XCTestCase {
    private var session: Session!
    private var sut: DrugAPIClient!

    private let testBaseURL = "https://apis.data.go.kr/1471000/DrbEasyDrugInfoService"
    private let testServiceKey = "test-key"

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = Session(configuration: configuration)
        sut = DrugAPIClient(serviceKey: testServiceKey, baseURL: testBaseURL, session: session)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        sut = nil
        session = nil
        super.tearDown()
    }

    func test_searchDrugs_whenValidResponse_thenReturnsDrugArray() async throws {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: self.testBaseURL)!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let json = """
            {
                "body": {
                    "items": [
                        {
                            "itemSeq": "200001234",
                            "itemName": "프로게스테론질정",
                            "entpName": "한국의약품"
                        }
                    ],
                    "totalCount": 1,
                    "pageNo": 1,
                    "numOfRows": 20
                }
            }
            """.data(using: .utf8)!
            return (response, json)
        }

        // when
        let result = try await sut.searchDrugs(keyword: "프로게스테론", pageNo: 1)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.itemName, "프로게스테론질정")
    }

    func test_searchDrugs_whenServerReturns500_thenThrowsError() async {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: self.testBaseURL)!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        // when / then
        do {
            _ = try await sut.searchDrugs(keyword: "테스트", pageNo: 1)
            XCTFail("Expected network error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_searchDrugs_whenResponseIsEmpty_thenReturnsEmptyArray() async throws {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: self.testBaseURL)!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let json = """
            {
                "body": {
                    "items": null,
                    "totalCount": 0,
                    "pageNo": 1,
                    "numOfRows": 20
                }
            }
            """.data(using: .utf8)!
            return (response, json)
        }

        // when
        let result = try await sut.searchDrugs(keyword: "없는약", pageNo: 1)

        // then
        XCTAssertTrue(result.isEmpty)
    }

    func test_searchDrugs_whenDecodingFails_thenThrowsError() async {
        // given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: self.testBaseURL)!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let malformedJSON = "{ invalid json }".data(using: .utf8)!
            return (response, malformedJSON)
        }

        // when / then
        do {
            _ = try await sut.searchDrugs(keyword: "테스트", pageNo: 1)
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
