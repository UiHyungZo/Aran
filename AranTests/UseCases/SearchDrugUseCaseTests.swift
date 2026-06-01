@testable import Aran
import XCTest

final class SearchDrugUseCaseTests: XCTestCase {
    private var repository: MockDrugRepository!
    private var sut: SearchDrugUseCase!

    override func setUp() {
        super.setUp()
        repository = MockDrugRepository()
        sut = SearchDrugUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func testExecute_withValidKeyword_returnsSearchResults() async throws {
        let drugs = [makeDrug(name: "프로게스테론")]
        repository.searchResult = DrugSearchResult(drugs: drugs, totalCount: 1, pageNo: 1)

        let result = try await sut.execute(keyword: "프로게스테론")

        XCTAssertEqual(result.drugs.map(\.itemSeq), drugs.map(\.itemSeq))
        XCTAssertEqual(result.totalCount, 1)
        XCTAssertEqual(repository.searchKeywords, ["프로게스테론"])
    }

    func testExecute_withEmptyKeyword_throwsInvalidInput() async {
        do {
            _ = try await sut.execute(keyword: "   ")
            XCTFail("빈 검색어는 invalidInput을 던져야 합니다.")
        } catch AppError.invalidInput {
            XCTAssertTrue(repository.searchKeywords.isEmpty)
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func testExecute_whenRepositoryFails_propagatesError() async {
        repository.shouldThrow = AppError.networkError(URLError(.notConnectedToInternet))

        do {
            _ = try await sut.execute(keyword: "프로게스테론")
            XCTFail("Repository 에러가 전파되어야 합니다.")
        } catch AppError.networkError {
            XCTAssertTrue(repository.searchKeywords.isEmpty)
        } catch {
            XCTFail("예상치 못한 에러 타입: \(error)")
        }
    }

    func testEnrich_returnsRepositoryEnrichedDrug() async throws {
        let drug = makeDrug(itemSeq: "A", name: "원본")
        let enrichedDrug = makeDrug(itemSeq: "A", name: "원본", component: "보강성분")
        repository.enrichedDrug = enrichedDrug

        let result = try await sut.enrich(drug)

        XCTAssertEqual(result.component, "보강성분")
    }
}

private extension SearchDrugUseCaseTests {
    func makeDrug(
        itemSeq: String = UUID().uuidString,
        name: String,
        component: String? = nil
    ) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: name,
            entpName: "제약사",
            component: component,
            efcyQesitm: "효능",
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
