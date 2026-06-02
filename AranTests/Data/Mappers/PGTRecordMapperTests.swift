@testable import Aran
import XCTest

final class PGTRecordMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let cycleRecordId = UUID()
        let testDate = Date()
        let model = PGTRecordModel(
            id: id,
            cycleRecordId: cycleRecordId,
            testDate: testDate,
            typeRawValue: PGTType.chromosomeCouple.rawValue,
            normalCount: 1,
            abnormalCount: 2,
            mosaicCount: 3,
            inconclusiveCount: 4,
            resultStatusRawValue: PGTResultStatus.borderline.rawValue,
            femaleChromosomeResultRawValue: ChromosomeResult.carrier.rawValue,
            maleChromosomeResultRawValue: ChromosomeResult.normal.rawValue,
            implantationTestTypeRawValue: ImplantationTestType.emma.rawValue,
            implantationResultRawValue: ImplantationResult.normal.rawValue,
            recommendedTransferWindow: "권장 창",
            memo: "메모"
        )

        // when
        let record = PGTRecordMapper.toDomain(model)

        // then
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.cycleRecordId, cycleRecordId)
        XCTAssertEqual(record.testDate, testDate)
        XCTAssertEqual(record.type, .chromosomeCouple)
        XCTAssertEqual(record.normalCount, 1)
        XCTAssertEqual(record.abnormalCount, 2)
        XCTAssertEqual(record.mosaicCount, 3)
        XCTAssertEqual(record.inconclusiveCount, 4)
        XCTAssertEqual(record.resultStatus, .borderline)
        XCTAssertEqual(record.femaleChromosomeResult, .carrier)
        XCTAssertEqual(record.maleChromosomeResult, .normal)
        XCTAssertEqual(record.implantationTestType, .emma)
        XCTAssertEqual(record.implantationResult, .normal)
        XCTAssertEqual(record.recommendedTransferWindow, "권장 창")
        XCTAssertEqual(record.memo, "메모")
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let record = PGTRecord(
            id: UUID(),
            cycleRecordId: UUID(),
            testDate: Date(),
            type: .implantation,
            normalCount: 0,
            abnormalCount: 0,
            mosaicCount: 0,
            inconclusiveCount: 1,
            resultStatus: .pending,
            femaleChromosomeResult: nil,
            maleChromosomeResult: nil,
            implantationTestType: .era,
            implantationResult: .receptive,
            recommendedTransferWindow: "132시간",
            memo: nil
        )

        // when
        let model = PGTRecordMapper.toModel(record)

        // then
        XCTAssertEqual(model.id, record.id)
        XCTAssertEqual(model.cycleRecordId, record.cycleRecordId)
        XCTAssertEqual(model.testDate, record.testDate)
        XCTAssertEqual(model.typeRawValue, PGTType.implantation.rawValue)
        XCTAssertEqual(model.inconclusiveCount, 1)
        XCTAssertEqual(model.resultStatusRawValue, PGTResultStatus.pending.rawValue)
        XCTAssertNil(model.femaleChromosomeResultRawValue)
        XCTAssertEqual(model.implantationTestTypeRawValue, ImplantationTestType.era.rawValue)
        XCTAssertEqual(model.implantationResultRawValue, ImplantationResult.receptive.rawValue)
        XCTAssertEqual(model.recommendedTransferWindow, "132시간")
        XCTAssertNil(model.memo)
    }

    func test_toDomain_whenRawValuesAreUnknown_thenUsesFallbacksAndNilDetails() {
        // given
        let model = PGTRecordModel(
            cycleRecordId: UUID(),
            testDate: Date(),
            typeRawValue: "알수없음",
            normalCount: 0,
            abnormalCount: 0,
            mosaicCount: 0,
            resultStatusRawValue: "알수없음",
            femaleChromosomeResultRawValue: "알수없음",
            implantationTestTypeRawValue: "알수없음",
            implantationResultRawValue: "알수없음"
        )

        // when
        let record = PGTRecordMapper.toDomain(model)

        // then
        XCTAssertEqual(record.type, .pgtA)
        XCTAssertNil(record.resultStatus)
        XCTAssertNil(record.femaleChromosomeResult)
        XCTAssertNil(record.implantationTestType)
        XCTAssertNil(record.implantationResult)
    }
}
