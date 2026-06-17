import Foundation
import AranDomain

public nonisolated struct DrugListResponseDTO: Decodable {
    public let body: DrugListBodyDTO
}

public nonisolated struct DrugListBodyDTO: Decodable {
    public let items: [DrugItemDTO]?
    public let totalCount: Int
    public let pageNo: Int
    public let numOfRows: Int
}

public nonisolated struct DrugItemDTO: Decodable {
    public let itemSeq: String
    public let itemName: String
    public let entpName: String
    public let materialName: String?
    public let efcyQesitm: String?
    public let useMethodQesitm: String?
    public let atpnWarnQesitm: String?
    public let atpnQesitm: String?
    public let intrcQesitm: String?
    public let seQesitm: String?
    public let depositMethodQesitm: String?
    public let itemImage: String?

    public nonisolated init(
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

    public nonisolated func toDomain() -> Drug {
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
