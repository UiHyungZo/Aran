@testable import Aran
import XCTest
import AranDomain

final class RecentDrugSearchMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let createdAt = Date()
        let model = RecentDrugSearchModel(id: id, keyword: "프로게스테론", createdAt: createdAt)

        // when
        let search = RecentDrugSearchMapper.toDomain(model)

        // then
        XCTAssertEqual(search.id, id)
        XCTAssertEqual(search.keyword, "프로게스테론")
        XCTAssertEqual(search.createdAt, createdAt)
    }
}
