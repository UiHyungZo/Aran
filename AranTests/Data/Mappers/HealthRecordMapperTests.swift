@testable import Aran
import XCTest
import AranDomain

final class HealthRecordMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let date = Date()
        let model = HealthRecordModel(
            id: id,
            type: HealthRecordType.amh,
            value: 2.4,
            unit: "ng/mL",
            recordDate: date,
            memo: "외부 검사"
        )

        // when
        let record = HealthRecordMapper.toDomain(model)

        // then
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.type, HealthRecordType.amh)
        XCTAssertEqual(record.value, 2.4)
        XCTAssertEqual(record.unit, "ng/mL")
        XCTAssertEqual(record.recordDate, date)
        XCTAssertEqual(record.memo, "외부 검사")
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let date = Date()
        let record = HealthRecord(
            id: id,
            type: "비타민D",
            value: 31.5,
            unit: "ng/mL",
            recordDate: date,
            memo: nil
        )

        // when
        let model = HealthRecordMapper.toModel(record)

        // then
        XCTAssertEqual(model.id, id)
        XCTAssertEqual(model.type, "비타민D")
        XCTAssertEqual(model.value, 31.5)
        XCTAssertEqual(model.unit, "ng/mL")
        XCTAssertEqual(model.recordDate, date)
        XCTAssertNil(model.memo)
    }
}
