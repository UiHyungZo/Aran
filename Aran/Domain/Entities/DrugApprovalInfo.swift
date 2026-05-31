import Foundation

struct DrugApprovalInfo: Equatable {
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
}
