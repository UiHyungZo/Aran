@testable import Aran
import XCTest

final class DrugMapperTests: XCTestCase {

    func test_toDomain_whenAllFieldsPresent_thenMapsCorrectly() {
        // given
        let dto = DrugItemDTO(
            itemSeq: "200001234",
            itemName: "프로게스테론질정",
            entpName: "한국의약품",
            efcyQesitm: "황체호르몬 보충",
            useMethodQesitm: "1일 2회 질 내 삽입",
            atpnWarnQesitm: nil,
            atpnQesitm: "임신 초기 사용 주의",
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: "실온 보관",
            itemImage: "https://example.com/image.jpg"
        )

        // when
        let drug = dto.toDomain()

        // then
        XCTAssertEqual(drug.itemSeq, "200001234")
        XCTAssertEqual(drug.itemName, "프로게스테론질정")
        XCTAssertEqual(drug.entpName, "한국의약품")
        XCTAssertEqual(drug.efcyQesitm, "황체호르몬 보충")
        XCTAssertEqual(drug.useMethodQesitm, "1일 2회 질 내 삽입")
        XCTAssertNil(drug.atpnWarnQesitm)
        XCTAssertNil(drug.intrcQesitm)
        XCTAssertNil(drug.seQesitm)
    }

    func test_toDomain_whenOptionalFieldsAreNil_thenEntityHasNilValues() {
        // given
        let dto = DrugItemDTO(
            itemSeq: "100001234",
            itemName: "테스트약",
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

        // when
        let drug = dto.toDomain()

        // then
        XCTAssertNil(drug.efcyQesitm)
        XCTAssertNil(drug.useMethodQesitm)
        XCTAssertNil(drug.atpnQesitm)
        XCTAssertNil(drug.depositMethodQesitm)
        XCTAssertNil(drug.itemImage)
    }

    func test_toDomain_whenImageIsNil_thenEntityImageIsNil() {
        // given
        let dto = DrugItemDTO(
            itemSeq: "100001234",
            itemName: "이미지없는약",
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

        // when
        let drug = dto.toDomain()

        // then
        XCTAssertNil(drug.itemImage)
        XCTAssertEqual(drug.itemName, "이미지없는약")
    }
}
