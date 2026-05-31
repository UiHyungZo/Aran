import Foundation

nonisolated struct DrugApprovalResponseDTO: Decodable {
    let body: DrugApprovalBodyDTO
}

nonisolated struct DrugApprovalBodyDTO: Decodable {
    let items: [DrugApprovalItemDTO]?
    let totalCount: Int?
    let pageNo: Int?
    let numOfRows: Int?
}

nonisolated struct DrugApprovalItemDTO: Decodable {
    let itemSeq: String
    let itemName: String?
    let entpName: String?
    let itemPermitDate: String?
    let barCode: String?
    let ediCode: String?
    let atcCode: String?
    let mainItemIngredient: String?
    let productType: String?
    let specialtyPublic: String?
    let bigProductImageURL: String?
    let rareDrugYN: String?

    enum CodingKeys: String, CodingKey {
        case itemSeq = "ITEM_SEQ"
        case itemName = "ITEM_NAME"
        case entpName = "ENTP_NAME"
        case itemPermitDate = "ITEM_PERMIT_DATE"
        case barCode = "BAR_CODE"
        case ediCode = "EDI_CODE"
        case atcCode = "ATC_CODE"
        case mainItemIngredient = "ITEM_INGR_NAME"
        case productType = "PRDUCT_TYPE"
        case specialtyPublic = "SPCLTY_PBLC"
        case bigProductImageURL = "BIG_PRDT_IMG_URL"
        case rareDrugYN = "RARE_DRUG_YN"
    }

    nonisolated init(
        itemSeq: String,
        itemName: String?,
        entpName: String?,
        itemPermitDate: String?,
        barCode: String?,
        ediCode: String?,
        atcCode: String?,
        mainItemIngredient: String?,
        productType: String? = nil,
        specialtyPublic: String? = nil,
        bigProductImageURL: String? = nil,
        rareDrugYN: String?
    ) {
        self.itemSeq = itemSeq
        self.itemName = itemName
        self.entpName = entpName
        self.itemPermitDate = itemPermitDate
        self.barCode = barCode
        self.ediCode = ediCode
        self.atcCode = atcCode
        self.mainItemIngredient = mainItemIngredient
        self.productType = productType
        self.specialtyPublic = specialtyPublic
        self.bigProductImageURL = bigProductImageURL
        self.rareDrugYN = rareDrugYN
    }

    nonisolated func toDomain() -> DrugApprovalInfo {
        DrugApprovalInfo(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            itemPermitDate: itemPermitDate,
            barCode: barCode,
            ediCode: ediCode,
            atcCode: atcCode,
            mainItemIngredient: mainItemIngredient,
            productType: productType,
            specialtyPublic: specialtyPublic,
            bigProductImageURL: bigProductImageURL,
            rareDrugYN: rareDrugYN
        )
    }
}
