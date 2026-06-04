import SwiftUI

struct FavoriteDrugListView: View {
    @ObservedObject var viewModel: DrugInfoViewModel
    let onAddDrug: (Drug) -> Void
    @State private var isDetailPresented = false

    var body: some View {
        Group {
            if viewModel.favoriteDrugs.isEmpty {
                emptyView
            } else {
                List {
                    ForEach(viewModel.favoriteDrugs) { favoriteDrug in
                        Button {
                            viewModel.selectFavorite(favoriteDrug)
                            isDetailPresented = true
                        } label: {
                            FavoriteDrugRow(favoriteDrug: favoriteDrug)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("favoriteList.item.\(favoriteDrug.itemSeq)")
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.removeFavorite(favoriteDrug)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets where viewModel.favoriteDrugs.indices.contains(index) {
                            viewModel.removeFavorite(viewModel.favoriteDrugs[index])
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AranColor.background)
            }
        }
        .background(AranColor.background)
        .navigationTitle("즐겨찾기")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadFavorites() }
        .navigationDestination(isPresented: $isDetailPresented) {
            if let drug = viewModel.selectedDrug {
                DrugDetailView(
                    drug: drug,
                    onAddDrug: onAddDrug,
                    isFavorite: viewModel.favoriteItemSeqs.contains(drug.itemSeq),
                    isLoadingDetail: viewModel.isDetailLoading,
                    onToggleFavorite: { viewModel.toggleFavorite(viewModel.selectedDrug ?? drug) }
                )
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "star")
                .font(.system(size: 44))
                .foregroundStyle(Color.secondary)
            Text("즐겨찾기한 약이 없어요")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)
            Text("약 상세 화면에서 별표를 눌러 저장할 수 있어요")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }
}

private struct FavoriteDrugRow: View {
    let favoriteDrug: FavoriteDrug

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(favoriteDrug.itemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            let subtitle = [favoriteDrug.component, favoriteDrug.entpName]
                .compactMap { $0 }
                .joined(separator: " · ")
            Text(subtitle.isEmpty ? favoriteDrug.entpName : subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)

            Text("자세히 보기")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AranColor.accentDrug)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
