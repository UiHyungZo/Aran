import Foundation
import AranDomain

public enum FavoriteDrugMapper {
    public static func toDomain(_ model: FavoriteDrugModel) -> FavoriteDrug {
        FavoriteDrug(
            id: model.id,
            itemSeq: model.itemSeq,
            itemName: model.itemName,
            entpName: model.entpName,
            component: model.component,
            efcyQesitm: model.efcyQesitm,
            useMethodQesitm: model.useMethodQesitm,
            atpnWarnQesitm: model.atpnWarnQesitm,
            atpnQesitm: model.atpnQesitm,
            intrcQesitm: model.intrcQesitm,
            seQesitm: model.seQesitm,
            depositMethodQesitm: model.depositMethodQesitm,
            itemImage: model.itemImage,
            createdAt: model.createdAt
        )
    }

    public static func toModel(_ favoriteDrug: FavoriteDrug) -> FavoriteDrugModel {
        FavoriteDrugModel(
            id: favoriteDrug.id,
            itemSeq: favoriteDrug.itemSeq,
            itemName: favoriteDrug.itemName,
            entpName: favoriteDrug.entpName,
            component: favoriteDrug.component,
            efcyQesitm: favoriteDrug.efcyQesitm,
            useMethodQesitm: favoriteDrug.useMethodQesitm,
            atpnWarnQesitm: favoriteDrug.atpnWarnQesitm,
            atpnQesitm: favoriteDrug.atpnQesitm,
            intrcQesitm: favoriteDrug.intrcQesitm,
            seQesitm: favoriteDrug.seQesitm,
            depositMethodQesitm: favoriteDrug.depositMethodQesitm,
            itemImage: favoriteDrug.itemImage,
            createdAt: favoriteDrug.createdAt
        )
    }
}
