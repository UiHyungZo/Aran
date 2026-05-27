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
