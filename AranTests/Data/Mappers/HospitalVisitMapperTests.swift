@testable import Aran
import XCTest
import AranDomain

final class HospitalVisitMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let date = Date()
        let model = HospitalVisitModel(
            id: id,
            visitDate: date,
            visitTypes: ["내원", "채혈"],
            memo: "오전"
        )

        // when
        let visit = HospitalVisitMapper.toDomain(model)

        // then
        XCTAssertEqual(visit.id, id)
        XCTAssertEqual(visit.visitDate, date)
        XCTAssertEqual(visit.visitTypes, ["내원", "채혈"])
        XCTAssertEqual(visit.memo, "오전")
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let date = Date()
        let visit = HospitalVisit(id: id, visitDate: date, visitTypes: ["초음파"], memo: nil)

        // when
        let model = HospitalVisitMapper.toModel(visit)

        // then
        XCTAssertEqual(model.id, id)
        XCTAssertEqual(model.visitDate, date)
        XCTAssertEqual(model.visitTypes, ["초음파"])
        XCTAssertNil(model.memo)
    }
}
