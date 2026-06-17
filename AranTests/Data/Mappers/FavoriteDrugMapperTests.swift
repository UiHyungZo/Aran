@testable import Aran
import XCTest
import AranDomain

final class FavoriteDrugMapperTests: XCTestCase {

    func test_toDomain_whenModelIsValid_thenAllFieldsMapped() {
        // given
        let id = UUID()
        let createdAt = Date()
        let model = FavoriteDrugModel(
            id: id,
            itemSeq: "A001",
            itemName: "프로게스테론",
            entpName: "제약사",
            component: "Progesterone",
            efcyQesitm: "효능",
            useMethodQesitm: "복용법",
            atpnWarnQesitm: "경고",
            atpnQesitm: "주의",
            intrcQesitm: "상호작용",
            seQesitm: "부작용",
            depositMethodQesitm: "보관",
            itemImage: "image-url",
            createdAt: createdAt
        )

        // when
        let favorite = FavoriteDrugMapper.toDomain(model)

        // then
        XCTAssertEqual(favorite.id, id)
        XCTAssertEqual(favorite.itemSeq, "A001")
        XCTAssertEqual(favorite.itemName, "프로게스테론")
        XCTAssertEqual(favorite.component, "Progesterone")
        XCTAssertEqual(favorite.createdAt, createdAt)
        XCTAssertEqual(favorite.itemImage, "image-url")
    }

    func test_toModel_whenEntityIsValid_thenAllFieldsMapped() {
        // given
        let createdAt = Date()
        let favorite = FavoriteDrug(
            id: UUID(),
            itemSeq: "B001",
            itemName: "에스트라디올",
            entpName: "제약사",
            component: nil,
            efcyQesitm: nil,
            useMethodQesitm: "복용법",
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: nil,
            createdAt: createdAt
        )

        // when
        let model = FavoriteDrugMapper.toModel(favorite)

        // then
        XCTAssertEqual(model.id, favorite.id)
        XCTAssertEqual(model.itemSeq, "B001")
        XCTAssertEqual(model.itemName, "에스트라디올")
        XCTAssertNil(model.component)
        XCTAssertEqual(model.useMethodQesitm, "복용법")
        XCTAssertEqual(model.createdAt, createdAt)
    }
}
