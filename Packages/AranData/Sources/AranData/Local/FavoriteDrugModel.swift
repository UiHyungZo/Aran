import Foundation
import SwiftData
import AranDomain

@Model
public final class FavoriteDrugModel {
    @Attribute(.unique) public var itemSeq: String
    public var id: UUID
    public var itemName: String
    public var entpName: String
    public var component: String?
    public var efcyQesitm: String?
    public var useMethodQesitm: String?
    public var atpnWarnQesitm: String?
    public var atpnQesitm: String?
    public var intrcQesitm: String?
    public var seQesitm: String?
    public var depositMethodQesitm: String?
    public var itemImage: String?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        itemSeq: String,
        itemName: String,
        entpName: String,
        component: String? = nil,
        efcyQesitm: String? = nil,
        useMethodQesitm: String? = nil,
        atpnWarnQesitm: String? = nil,
        atpnQesitm: String? = nil,
        intrcQesitm: String? = nil,
        seQesitm: String? = nil,
        depositMethodQesitm: String? = nil,
        itemImage: String? = nil,
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
