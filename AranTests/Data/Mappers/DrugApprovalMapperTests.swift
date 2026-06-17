import XCTest
@testable import Aran
import AranDomain

final class DrugApprovalMapperTests: XCTestCase {
    private func decodeItem() throws -> DrugApprovalItemDTO {
        let eeDoc = "<DOC title=\"효능효과\"><SECTION title=\"\"><ARTICLE title=\"1. 저혈당시의 에너지 보급\" /></SECTION></DOC>"
        let udDoc = "<DOC title=\"용법용량\"><SECTION title=\"\"><ARTICLE title=\"\"><PARAGRAPH><![CDATA[성인 : 1회 20~500 mL 정맥주사한다.]]></PARAGRAPH></ARTICLE></SECTION></DOC>"
        let nbDoc = "<DOC title=\"주의\"><SECTION title=\"\"><ARTICLE title=\"1. 경고\"><PARAGRAPH><![CDATA[유리파편 혼입에 주의할 것.]]></PARAGRAPH></ARTICLE><ARTICLE title=\"2. 투여 금기\"><PARAGRAPH><![CDATA[고혈당 환자.]]></PARAGRAPH></ARTICLE></SECTION></DOC>"

        let json: [String: Any] = [
            "body": [
                "pageNo": 1,
                "totalCount": 1,
                "numOfRows": 1,
                "items": [[
                    "ITEM_SEQ": "195700004",
                    "ITEM_NAME": "대한포도당주사액(10%)",
                    "ENTP_NAME": "대한약품공업(주)",
                    "ETC_OTC_CODE": "전문의약품",
                    "STORAGE_METHOD": "밀봉용기, 실온(1-30℃)보관",
                    "MAIN_ITEM_INGR": "[M040702]포도당",
                    "ATC_CODE": "B05BA03",
                    "EE_DOC_DATA": eeDoc,
                    "UD_DOC_DATA": udDoc,
                    "NB_DOC_DATA": nbDoc
                ]]
            ]
        ]

        let data = try JSONSerialization.data(withJSONObject: json)
        let response = try JSONDecoder().decode(DrugApprovalResponseDTO.self, from: data)
        return try XCTUnwrap(response.body.items?.first)
    }

    func test_toDrug_parsesDocDataIntoDrugFields() throws {
        let drug = try decodeItem().toDrug()

        XCTAssertEqual(drug.itemSeq, "195700004")
        XCTAssertEqual(drug.itemName, "대한포도당주사액(10%)")
        XCTAssertEqual(drug.component, "포도당")
        XCTAssertEqual(drug.depositMethodQesitm, "밀봉용기, 실온(1-30℃)보관")

        XCTAssertEqual(drug.efcyQesitm, "1. 저혈당시의 에너지 보급")
        XCTAssertEqual(drug.useMethodQesitm?.contains("정맥주사"), true)

        // 경고 섹션만 atpnWarn으로 분리
        XCTAssertEqual(drug.atpnWarnQesitm?.contains("유리파편"), true)
        XCTAssertEqual(drug.atpnWarnQesitm?.contains("고혈당"), false)
        // 경고 외 섹션은 atpn으로
        XCTAssertEqual(drug.atpnQesitm?.contains("고혈당"), true)
        XCTAssertEqual(drug.atpnQesitm?.contains("유리파편"), false)
    }

    func test_toDrug_buildsApprovalInfo() throws {
        let drug = try decodeItem().toDrug()

        XCTAssertEqual(drug.approvalInfo?.specialtyPublic, "전문의약품")
        XCTAssertEqual(drug.approvalInfo?.mainItemIngredient, "포도당")
        XCTAssertEqual(drug.approvalInfo?.atcCode, "B05BA03")
    }

    func test_toDomain_mapsMetadataFields() throws {
        let info = try decodeItem().toDomain()

        XCTAssertEqual(info.itemSeq, "195700004")
        XCTAssertEqual(info.mainItemIngredient, "포도당")
        XCTAssertEqual(info.specialtyPublic, "전문의약품")
        XCTAssertEqual(info.atcCode, "B05BA03")
    }
}
