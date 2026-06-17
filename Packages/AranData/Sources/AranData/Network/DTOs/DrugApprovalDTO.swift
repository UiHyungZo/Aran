import Foundation
import AranDomain

public nonisolated struct DrugApprovalResponseDTO: Decodable {
    public let body: DrugApprovalBodyDTO
}

public nonisolated struct DrugApprovalBodyDTO: Decodable {
    public let items: [DrugApprovalItemDTO]?
    public let totalCount: Int?
    public let pageNo: Int?
    public let numOfRows: Int?
}

public nonisolated struct DrugApprovalItemDTO: Decodable {
    public let itemSeq: String
    public let itemName: String?
    public let entpName: String?
    public let itemPermitDate: String?
    public let etcOtcCode: String?
    public let materialName: String?
    public let storageMethod: String?
    public let eeDocData: String?
    public let udDocData: String?
    public let nbDocData: String?
    public let mainItemIngredient: String?
    public let atcCode: String?
    public let ediCode: String?
    public let barCode: String?
    public let rareDrugYN: String?

    public enum CodingKeys: String, CodingKey {
        case itemSeq = "ITEM_SEQ"
        case itemName = "ITEM_NAME"
        case entpName = "ENTP_NAME"
        case itemPermitDate = "ITEM_PERMIT_DATE"
        case etcOtcCode = "ETC_OTC_CODE"
        case materialName = "MATERIAL_NAME"
        case storageMethod = "STORAGE_METHOD"
        case eeDocData = "EE_DOC_DATA"
        case udDocData = "UD_DOC_DATA"
        case nbDocData = "NB_DOC_DATA"
        case mainItemIngredient = "MAIN_ITEM_INGR"
        case atcCode = "ATC_CODE"
        case ediCode = "EDI_CODE"
        case barCode = "BAR_CODE"
        case rareDrugYN = "RARE_DRUG_YN"
    }

    /// 허가정보 섹션에 표시할 메타데이터
    public nonisolated func toDomain() -> DrugApprovalInfo {
        DrugApprovalInfo(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            itemPermitDate: itemPermitDate,
            barCode: barCode,
            ediCode: ediCode,
            atcCode: atcCode,
            mainItemIngredient: cleanedIngredient,
            productType: nil,
            specialtyPublic: etcOtcCode,
            bigProductImageURL: nil,
            rareDrugYN: rareDrugYN
        )
    }

    /// primary 검색 결과용 — XML doc 데이터를 파싱해 효능·용법·주의사항까지 채운 완전한 Drug
    public nonisolated func toDrug() -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName ?? "",
            entpName: entpName ?? "",
            component: cleanedIngredient ?? materialNameComponent,
            efcyQesitm: eeDocData.flatMap(DocDataXMLParser.extractText),
            useMethodQesitm: udDocData.flatMap(DocDataXMLParser.extractText),
            atpnWarnQesitm: nbDocData.flatMap { DocDataXMLParser.extractArticles(from: $0, titleContaining: "경고") },
            atpnQesitm: nbDocData.flatMap { DocDataXMLParser.extractArticles(from: $0, titleExcluding: "경고") },
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: storageMethod?.nilIfBlank,
            itemImage: nil,
            approvalInfo: toDomain()
        )
    }

    // MARK: - Helpers

    /// "[M040702]포도당" → "포도당"
    private var cleanedIngredient: String? {
        guard let raw = mainItemIngredient?.nilIfBlank else { return nil }
        let stripped = raw.replacingOccurrences(of: "\\[[^\\]]*\\]", with: "", options: .regularExpression)
        return stripped.nilIfBlank
    }

    /// "총량 : ... |성분명 : 포도당|분량 : ..." 형태에서 성분명만 추출
    private var materialNameComponent: String? {
        guard let raw = materialName?.nilIfBlank else { return nil }
        for part in raw.components(separatedBy: "|") {
            let kv = part.components(separatedBy: ":")
            if kv.count >= 2, kv[0].contains("성분명") {
                return kv[1].trimmingCharacters(in: .whitespaces).nilIfBlank
            }
        }
        return nil
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
