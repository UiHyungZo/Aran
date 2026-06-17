import Foundation

public struct FavoriteDrug: Identifiable, Equatable {
    public let id: UUID
    public let itemSeq: String
    public let itemName: String
    public let entpName: String
    public let component: String?
    public let efcyQesitm: String?
    public let useMethodQesitm: String?
    public let atpnWarnQesitm: String?
    public let atpnQesitm: String?
    public let intrcQesitm: String?
    public let seQesitm: String?
    public let depositMethodQesitm: String?
    public let itemImage: String?
    public let createdAt: Date

    public init(
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
    public init(drug: Drug, createdAt: Date = Date()) {
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

    public var drug: Drug {
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
