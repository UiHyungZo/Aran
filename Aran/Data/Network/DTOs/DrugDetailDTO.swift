import Foundation

nonisolated struct DrugDetailResponseDTO: Decodable, Sendable {
    let body: DrugDetailBodyDTO
}

nonisolated struct DrugDetailBodyDTO: Decodable, Sendable {
    let items: [DrugDetailItemDTO]?
}

nonisolated struct DrugDetailItemDTO: Decodable, Sendable {
    let itemSeq: String
    let itemName: String
    let entpName: String
    let efcyQesitm: String?
    let useMethodQesitm: String?
    let atpnWarnQesitm: String?
    let atpnQesitm: String?
    let intrcQesitm: String?
    let seQesitm: String?
    let depositMethodQesitm: String?
    let itemImage: String?

    nonisolated func toDomain() -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            efcyQesitm: efcyQesitm,
            useMethodQesitm: useMethodQesitm,
            atpnWarnQesitm: atpnWarnQesitm,
            atpnQesitm: atpnQesitm,
            intrcQesitm: intrcQesitm,
            seQesitm: seQesitm,
            depositMethodQesitm: depositMethodQesitm,
            itemImage: itemImage
        )
    }
}
