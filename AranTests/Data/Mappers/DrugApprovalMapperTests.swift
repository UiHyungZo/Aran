@testable import Aran
import XCTest

final class DrugApprovalMapperTests: XCTestCase {
    func test_toDomain_mapsApprovalFields() {
        let dto = DrugApprovalItemDTO(
            itemSeq: "200001234",
            itemName: "프로게스테론질정",
            entpName: "제약사",
            itemPermitDate: "20210101",
            barCode: "8801234567890",
            ediCode: "123456789",
            atcCode: "G03DA04",
            mainItemIngredient: "프로게스테론",
            productType: "[02450]부신호르몬제",
            specialtyPublic: "전문의약품",
            bigProductImageURL: "https://example.com/image",
            rareDrugYN: "N"
        )

        let approvalInfo = dto.toDomain()

        XCTAssertEqual(approvalInfo.itemSeq, "200001234")
        XCTAssertEqual(approvalInfo.mainItemIngredient, "프로게스테론")
        XCTAssertEqual(approvalInfo.barCode, "8801234567890")
        XCTAssertEqual(approvalInfo.ediCode, "123456789")
        XCTAssertEqual(approvalInfo.atcCode, "G03DA04")
        XCTAssertEqual(approvalInfo.productType, "[02450]부신호르몬제")
        XCTAssertEqual(approvalInfo.specialtyPublic, "전문의약품")
    }
}
