import Foundation
import AranDomain

nonisolated struct DrugListResponseDTO: Decodable {
    let body: DrugListBodyDTO
}

nonisolated struct DrugListBodyDTO: Decodable {
    let items: [DrugItemDTO]?
    let totalCount: Int
    let pageNo: Int
    let numOfRows: Int
}

nonisolated struct DrugItemDTO: Decodable {
    let itemSeq: String
    let itemName: String
    let entpName: String
    let materialName: String?
    let efcyQesitm: String?
    let useMethodQesitm: String?
    let atpnWarnQesitm: String?
    let atpnQesitm: String?
    let intrcQesitm: String?
    let seQesitm: String?
    let depositMethodQesitm: String?
    let itemImage: String?

    nonisolated init(
        itemSeq: String,
        itemName: String,
        entpName: String,
        materialName: String? = nil,
        efcyQesitm: String?,
        useMethodQesitm: String?,
        atpnWarnQesitm: String?,
        atpnQesitm: String?,
        intrcQesitm: String?,
        seQesitm: String?,
        depositMethodQesitm: String?,
        itemImage: String?
    ) {
        self.itemSeq = itemSeq
        self.itemName = itemName
        self.entpName = entpName
        self.materialName = materialName
        self.efcyQesitm = efcyQesitm
        self.useMethodQesitm = useMethodQesitm
        self.atpnWarnQesitm = atpnWarnQesitm
        self.atpnQesitm = atpnQesitm
        self.intrcQesitm = intrcQesitm
        self.seQesitm = seQesitm
        self.depositMethodQesitm = depositMethodQesitm
        self.itemImage = itemImage
    }

    nonisolated func toDomain() -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            component: materialName,
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
