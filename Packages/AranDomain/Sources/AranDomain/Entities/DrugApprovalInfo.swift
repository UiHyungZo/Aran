import Foundation

public struct DrugApprovalInfo: Equatable {
    public let itemSeq: String
    public let itemName: String?
    public let entpName: String?
    public let itemPermitDate: String?
    public let barCode: String?
    public let ediCode: String?
    public let atcCode: String?
    public let mainItemIngredient: String?
    public let productType: String?
    public let specialtyPublic: String?
    public let bigProductImageURL: String?
    public let rareDrugYN: String?

    public init(
        itemSeq: String,
        itemName: String?,
        entpName: String?,
        itemPermitDate: String?,
        barCode: String?,
        ediCode: String?,
        atcCode: String?,
        mainItemIngredient: String?,
        productType: String?,
        specialtyPublic: String?,
        bigProductImageURL: String?,
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
}
