import Foundation
import SwiftData
import AranDomain

@Model
final class FavoriteDrugModel {
    @Attribute(.unique) var itemSeq: String
    var id: UUID
    var itemName: String
    var entpName: String
    var component: String?
    var efcyQesitm: String?
    var useMethodQesitm: String?
    var atpnWarnQesitm: String?
    var atpnQesitm: String?
    var intrcQesitm: String?
    var seQesitm: String?
    var depositMethodQesitm: String?
    var itemImage: String?
    var createdAt: Date

    init(
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
