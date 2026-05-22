import Foundation

nonisolated struct DrugDetailResponseDTO: Decodable {
    let body: DrugDetailBodyDTO
}

nonisolated struct DrugDetailBodyDTO: Decodable {
    let items: [DrugDetailItemDTO]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let array = try? container.decodeIfPresent([DrugDetailItemDTO].self, forKey: .items) {
            items = array
        } else if let single = try? container.decodeIfPresent(DrugDetailItemDTO.self, forKey: .items) {
            items = [single]
        } else {
            items = nil
        }
    }

    enum CodingKeys: String, CodingKey { case items }
}

nonisolated struct DrugDetailItemDTO: Decodable {
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
