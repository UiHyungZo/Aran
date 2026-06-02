@testable import Aran
import XCTest

final class TransferRecordMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let date = Date()
        let model = TransferRecordModel(
            id: id,
            cycleNumber: 2,
            date: date,
            embryoGrade: "4AA",
            embryoCount: 2,
            transferTypeRawValue: TransferType.frozen.rawValue,
            resultRawValue: TransferResult.pregnant.rawValue,
            memo: "메모"
        )

        // when
        let record = TransferRecordMapper.toDomain(model)

        // then
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.cycleNumber, 2)
        XCTAssertEqual(record.date, date)
        XCTAssertEqual(record.embryoGrade, "4AA")
        XCTAssertEqual(record.embryoCount, 2)
        XCTAssertEqual(record.transferType, .frozen)
        XCTAssertEqual(record.result, .pregnant)
        XCTAssertEqual(record.memo, "메모")
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let record = TransferRecord(
            id: UUID(),
            cycleNumber: 3,
            date: Date(),
            embryoGrade: "5AA",
            embryoCount: 1,
            transferType: .fresh,
            result: .notPregnant,
            memo: nil
        )

        // when
        let model = TransferRecordMapper.toModel(record)

        // then
        XCTAssertEqual(model.id, record.id)
        XCTAssertEqual(model.cycleNumber, 3)
        XCTAssertEqual(model.date, record.date)
        XCTAssertEqual(model.embryoGrade, "5AA")
        XCTAssertEqual(model.embryoCount, 1)
        XCTAssertEqual(model.transferTypeRawValue, TransferType.fresh.rawValue)
        XCTAssertEqual(model.resultRawValue, TransferResult.notPregnant.rawValue)
        XCTAssertNil(model.memo)
    }

    func test_toDomain_whenRawValuesAreUnknown_thenUsesFallbacks() {
        // given
        let model = TransferRecordModel(
            date: Date(),
            embryoGrade: "3BB",
            embryoCount: 1,
            transferTypeRawValue: "알수없음",
            resultRawValue: "알수없음"
        )

        // when
        let record = TransferRecordMapper.toDomain(model)

        // then
        XCTAssertEqual(record.transferType, .fresh)
        XCTAssertEqual(record.result, .waiting)
    }
}
