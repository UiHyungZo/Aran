import SwiftUI

struct DrugDetailView: View {

    let drug: Drug
    let onAddDrug: (Drug) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                if let warning = drug.atpnWarnQesitm { warningSection(warning) }
                if let efcy = drug.efcyQesitm { detailSection(title: "효능", content: efcy) }
                if let use = drug.useMethodQesitm { detailSection(title: "사용법", content: use) }
                if let atpn = drug.atpnQesitm { detailSection(title: "주의사항", content: atpn) }
                if let deposit = drug.depositMethodQesitm { detailSection(title: "보관법", content: deposit) }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("약 상세")
        .navigationBarTitleDisplayMode(.inline)
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
