@testable import Aran
import XCTest
import AranDomain

final class MenstrualCycleMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let startDate = Date()
        let model = MenstrualCycleModel(id: id, startDate: startDate, cycleLength: 30, periodLength: 6)

        // when
        let cycle = MenstrualCycleMapper.toDomain(model)

        // then
        XCTAssertEqual(cycle.id, id)
        XCTAssertEqual(cycle.startDate, startDate)
        XCTAssertEqual(cycle.cycleLength, 30)
        XCTAssertEqual(cycle.periodLength, 6)
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let startDate = Date()
        let cycle = MenstrualCycle(id: id, startDate: startDate, cycleLength: 32, periodLength: 4)

        // when
        let model = MenstrualCycleMapper.toModel(cycle)

        // then
        XCTAssertEqual(model.id, id)
        XCTAssertEqual(model.startDate, startDate)
        XCTAssertEqual(model.cycleLength, 32)
        XCTAssertEqual(model.periodLength, 4)
    }
}
