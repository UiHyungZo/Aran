import Foundation
import AranDomain

#if DEBUG
enum UITestEnvironment {
    static let launchArgument = "-ui-testing"

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }

    static func makeDrugRepositoryOverride() -> DrugRepositoryProtocol? {
        isEnabled ? UITestDrugRepository() : nil
    }
}

private final class UITestDrugRepository: DrugRepositoryProtocol {
    private let testDrug = Drug(
        itemSeq: "UITEST-DRUG-001",
        itemName: "프로게스테론테스트정",
        entpName: "아란제약",
        component: "프로게스테론",
        efcyQesitm: "UI 테스트용 효능 정보입니다.",
        useMethodQesitm: "UI 테스트용 사용법 정보입니다.",
        atpnWarnQesitm: nil,
        atpnQesitm: "UI 테스트용 주의사항 정보입니다.",
        intrcQesitm: nil,
        seQesitm: nil,
        depositMethodQesitm: nil,
        itemImage: nil,
        approvalInfo: DrugApprovalInfo(
            itemSeq: "UITEST-DRUG-001",
            itemName: "프로게스테론테스트정",
            entpName: "아란제약",
            itemPermitDate: "20260602",
            barCode: nil,
            ediCode: "UITEST001",
            atcCode: nil,
            mainItemIngredient: "프로게스테론",
            productType: "정제",
            specialtyPublic: "일반의약품",
            bigProductImageURL: nil,
            rareDrugYN: "N"
        )
    )

    func search(keyword: String, pageNo: Int) async throws -> DrugSearchResult {
        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedKeyword == "스크롤" {
            let totalCount = 40
            let pageSize = 20
            let start = (pageNo - 1) * pageSize
            let drugs = (start..<min(start + pageSize, totalCount)).map { i in
                Drug(
                    itemSeq: "UITEST-PAGE-\(i)",
                    itemName: "페이지네이션약\(i)",
                    entpName: "아란제약",
                    component: nil,
                    efcyQesitm: "효능\(i)",
                    useMethodQesitm: "사용법\(i)",
                    atpnWarnQesitm: nil,
                    atpnQesitm: nil,
                    intrcQesitm: nil,
                    seQesitm: nil,
                    depositMethodQesitm: nil,
                    itemImage: nil
                )
            }
            return DrugSearchResult(drugs: drugs, totalCount: totalCount, pageNo: pageNo)
        }
        let drugs = normalizedKeyword.isEmpty ? [] : [testDrug]
        return DrugSearchResult(drugs: drugs, totalCount: drugs.count, pageNo: pageNo)
    }

    func enrich(_ drug: Drug) async throws -> Drug {
        drug.itemSeq == testDrug.itemSeq ? drug.merging(detail: testDrug) : drug
    }
}
#else
enum UITestEnvironment {
    static var isEnabled: Bool { false }
    static func makeDrugRepositoryOverride() -> DrugRepositoryProtocol? { nil }
}
#endif
