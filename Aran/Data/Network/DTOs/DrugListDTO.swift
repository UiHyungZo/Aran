import Foundation

struct DrugListResponseDTO: Decodable {
    let body: DrugListBodyDTO
}

struct DrugListBodyDTO: Decodable {
    let items: [DrugItemDTO]?
    let totalCount: Int
    let pageNo: Int
    let numOfRows: Int
}

struct DrugItemDTO: Decodable {
    let itemSeq: String
    let itemName: String
    let entpName: String
    let itemImage: String?

    func toDomain() -> Drug {
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
