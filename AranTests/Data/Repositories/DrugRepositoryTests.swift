@testable import Aran
import XCTest

final class DrugRepositoryTests: XCTestCase {
    private var mockAPIClient: MockDrugAPIClient!
    private var sut: DrugRepository!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockDrugAPIClient()
        sut = DrugRepository(apiClient: mockAPIClient)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        super.tearDown()
    }

    func test_search_whenAPIReturnsItems_thenReturnsDrugs() async throws {
        // given
        let drugs = [makeDrug(name: "프로게스테론")]
        mockAPIClient.searchResult = .success(drugs)

        // when
        let result = try await sut.search(keyword: "프로게스테론", pageNo: 1)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.itemName, "프로게스테론")
    }

    func test_search_whenAPIFails_thenThrowsAppError() async {
        // given
        mockAPIClient.searchResult = .failure(URLError(.notConnectedToInternet))

        // when / then
        do {
            _ = try await sut.search(keyword: "테스트", pageNo: 1)
            XCTFail("Expected AppError")
        } catch let error as AppError {
            if case .networkError = error {
                // success
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError, got \(error)")
        }
    }

    func test_search_whenAPIReturnsEmpty_thenReturnsEmptyArray() async throws {
        // given
        mockAPIClient.searchResult = .success([])

        // when
        let result = try await sut.search(keyword: "없는약", pageNo: 1)

        // then
        XCTAssertTrue(result.isEmpty)
    }
}

// MARK: - Helpers

private extension DrugRepositoryTests {
    func makeDrug(name: String) -> Drug {
        Drug(
            itemSeq: "200001234",
            itemName: name,
            entpName: "테스트제약",
            efcyQesitm: nil,
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil
        )
    }
}
