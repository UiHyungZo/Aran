import Foundation

nonisolated struct DrugListResponseDTO: Decodable, Sendable {
    let body: DrugListBodyDTO
}

nonisolated struct DrugListBodyDTO: Decodable, Sendable {
    let items: [DrugItemDTO]?
    let totalCount: Int
    let pageNo: Int
    let numOfRows: Int
}

nonisolated struct DrugItemDTO: Decodable, Sendable {
    let itemSeq: String
    let itemName: String
    let entpName: String
    let itemImage: String?

    nonisolated func toDomain() -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            efcyQesitm: nil,
            useMethodQesitm: nil,
            atpnWarnQesitm: nil,
            atpnQesitm: nil,
            intrcQesitm: nil,
            seQesitm: nil,
            depositMethodQesitm: nil,
            itemImage: itemImage
        )
    }
}
