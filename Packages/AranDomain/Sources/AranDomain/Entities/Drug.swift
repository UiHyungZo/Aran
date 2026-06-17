import Foundation

public struct Drug {
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
    public let approvalInfo: DrugApprovalInfo?

    public init(
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

    public func merging(detail: Drug) -> Drug {
        Drug(
            itemSeq: itemSeq,
            itemName: itemName,
            entpName: entpName,
            component: component?.nilIfBlank ?? detail.component,
            efcyQesitm: efcyQesitm?.nilIfBlank ?? detail.efcyQesitm,
            useMethodQesitm: useMethodQesitm?.nilIfBlank ?? detail.useMethodQesitm,
            atpnWarnQesitm: atpnWarnQesitm?.nilIfBlank ?? detail.atpnWarnQesitm,
            atpnQesitm: atpnQesitm?.nilIfBlank ?? detail.atpnQesitm,
            intrcQesitm: intrcQesitm?.nilIfBlank ?? detail.intrcQesitm,
            seQesitm: seQesitm?.nilIfBlank ?? detail.seQesitm,
            depositMethodQesitm: depositMethodQesitm?.nilIfBlank ?? detail.depositMethodQesitm,
            itemImage: itemImage?.nilIfBlank ?? detail.itemImage,
            approvalInfo: detail.approvalInfo ?? approvalInfo
        )
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
