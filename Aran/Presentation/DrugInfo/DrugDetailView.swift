import SwiftUI

struct DrugDetailView: View {
    let drug: Drug
    let onAddDrug: (Drug) -> Void
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                if let warning = drug.atpnWarnQesitm { warningSection(warning) }
                if let efcy = drug.efcyQesitm { detailSection(title: "효능", content: efcy) }
                if let use = drug.useMethodQesitm { detailSection(title: "사용법", content: use) }
                if let atpn = drug.atpnQesitm { detailSection(title: "주의사항", content: atpn) }
                if let interaction = drug.intrcQesitm { detailSection(title: "상호작용", content: interaction) }
                if let sideEffect = drug.seQesitm { detailSection(title: "부작용", content: sideEffect) }
                if let deposit = drug.depositMethodQesitm { detailSection(title: "보관법", content: deposit) }
                if let approvalInfo = drug.approvalInfo {
                    approvalSection(approvalInfo)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("약 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onToggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? Color.yellow : Color.secondary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { addButton }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(drug.itemName)
                .font(.system(size: 20, weight: .bold))

            Text(drug.entpName)
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)

            if let efcy = drug.efcyQesitm {
                Text(efcy.prefix(30))
                    .font(.system(size: 12))
                    .foregroundStyle(AranColor.primary)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AranColor.primary.opacity(0.1))
                    .clipShape(Capsule())
            } else if let component = drug.component, !component.isEmpty {
                Text(component)
                    .font(.system(size: 12))
                    .foregroundStyle(AranColor.primary)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AranColor.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Warning Section

    private func warningSection(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.orange)
                .padding(.top, 2)
            Text(text)
                .font(.system(size: 14))
                .lineSpacing(3)
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Detail Section

    private func detailSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(content)
                .font(.system(size: 15))
                .lineSpacing(4)
        }
    }

    private func approvalSection(_ approvalInfo: DrugApprovalInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("허가 정보")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)

            VStack(alignment: .leading, spacing: 6) {
                approvalRow(title: "성분", value: approvalInfo.mainItemIngredient)
                approvalRow(title: "구분", value: approvalInfo.specialtyPublic)
                approvalRow(title: "분류", value: approvalInfo.productType)
                approvalRow(title: "허가일자", value: approvalInfo.itemPermitDate)
                approvalRow(title: "EDI 코드", value: approvalInfo.ediCode)
            }
        }
    }

    @ViewBuilder
    private func approvalRow(title: String, value: String?) -> some View {
        if let value, !value.isEmpty {
            HStack(alignment: .top, spacing: 8) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 58, alignment: .leading)
                Text(value)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.primary)
            }
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            onAddDrug(drug)
        } label: {
            Text("이 약 추가하기 (약/주사 탭)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AranColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}
