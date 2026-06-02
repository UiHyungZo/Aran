import Foundation

struct FavoriteDrug: Identifiable, Equatable {
    let id: UUID
    let itemSeq: String
    let itemName: String
    let entpName: String
    let component: String?
    let efcyQesitm: String?
    let useMethodQesitm: String?
    let atpnWarnQesitm: String?
    let atpnQesitm: String?
    let intrcQesitm: String?
    let seQesitm: String?
    let depositMethodQesitm: String?
    let itemImage: String?
    let createdAt: Date

    init(
        id: UUID,
        itemSeq: String,
        itemName: String,
        entpName: String,
        component: String?,
        efcyQesitm: String?,
        useMethodQesitm: String?,
        atpnWarnQesitm: String?,
        atpnQesitm: String?,
        intrcQesitm: String?,
        seQesitm: String?,
        depositMethodQesitm: String?,
        itemImage: String?,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemSeq = itemSeq
        self.itemName = itemName
        self.entpName = entpName
        self.component = component
        self.efcyQesitm = efcyQesitm
        self.useMethodQesitm = useMethodQesitm
        self.atpnWarnQesitm = atpnWarnQesitm
        self.atpnQesitm = atpnQesitm
        self.intrcQesitm = intrcQesitm
        self.seQesitm = seQesitm
        self.depositMethodQesitm = depositMethodQesitm
        self.itemImage = itemImage
        self.createdAt = createdAt
    }
}

extension FavoriteDrug {
    init(drug: Drug, createdAt: Date = Date()) {
        self.init(
            id: UUID(),
            itemSeq: drug.itemSeq,
            itemName: drug.itemName,
            entpName: drug.entpName,
            component: drug.component,
            efcyQesitm: drug.efcyQesitm,
            useMethodQesitm: drug.useMethodQesitm,
            atpnWarnQesitm: drug.atpnWarnQesitm,
            atpnQesitm: drug.atpnQesitm,
            intrcQesitm: drug.intrcQesitm,
            seQesitm: drug.seQesitm,
            depositMethodQesitm: drug.depositMethodQesitm,
            itemImage: drug.itemImage,
            createdAt: createdAt
        )
    }

    var drug: Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            component: component,
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
