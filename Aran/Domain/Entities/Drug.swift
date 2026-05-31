import Foundation

struct Drug {
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
    let approvalInfo: DrugApprovalInfo?

    init(
        itemSeq: String,
        itemName: String,
        entpName: String,
        component: String? = nil,
        efcyQesitm: String?,
        useMethodQesitm: String?,
        atpnWarnQesitm: String?,
        atpnQesitm: String?,
        intrcQesitm: String?,
        seQesitm: String?,
        depositMethodQesitm: String?,
        itemImage: String?,
        approvalInfo: DrugApprovalInfo? = nil
    ) {
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
        self.approvalInfo = approvalInfo
    }

    func enriched(with approvalInfo: DrugApprovalInfo) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            component: approvalInfo.mainItemIngredient?.nilIfBlank ?? component,
            efcyQesitm: efcyQesitm,
            useMethodQesitm: useMethodQesitm,
            atpnWarnQesitm: atpnWarnQesitm,
            atpnQesitm: atpnQesitm,
            intrcQesitm: intrcQesitm,
            seQesitm: seQesitm,
            depositMethodQesitm: depositMethodQesitm,
            itemImage: itemImage,
            approvalInfo: approvalInfo
        )
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
