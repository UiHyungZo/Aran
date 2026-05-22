import SwiftUI

struct DrugInfoView: View {
    @StateObject private var viewModel: DrugInfoViewModel
    let onAddDrug: (Drug) -> Void

    @FocusState private var isSearchFocused: Bool

    init(viewModel: DrugInfoViewModel, onAddDrug: @escaping (Drug) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onAddDrug = onAddDrug
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                if viewModel.showDebugChip {
                    debounceChip
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider()

                contentView
            }
            .navigationTitle("약 정보")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: Binding(
                get: { viewModel.selectedDrug != nil },
                set: { if !$0 { viewModel.selectedDrug = nil } }
            )) {
                if let drug = viewModel.selectedDrug {
                    DrugDetailView(drug: drug, onAddDrug: onAddDrug)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.showDebugChip)
        .alert("상세 정보 오류", isPresented: Binding(
            get: { viewModel.detailError != nil },
            set: { if !$0 { viewModel.detailError = nil } }
        )) {
            Button("확인") {}
        } message: {
            Text(viewModel.detailError ?? "")
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.gray)

            TextField("약 이름으로 검색하세요", text: $viewModel.searchText)
                .focused($isSearchFocused)
                .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.gray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Debug Chip (포트폴리오용: Combine debounce 시각화)

    private var debounceChip: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Combine .debounce(0.3s) → API 호출 완료")
                .font(.system(size: 12))
                .foregroundStyle(Color.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .initial: initialView
        case .loading: loadingView
        case let .results(drugs): resultsView(drugs: drugs)
        case .empty: emptyView
        case let .error(message): errorView(message: message)
        }
    }

    // MARK: Initial

    private var initialView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !viewModel.recentSearches.isEmpty {
                    Text("최근 검색")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 4)

                    ForEach(viewModel.recentSearches, id: \.self) { keyword in
                        recentSearchRow(keyword)
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }

                Spacer(minLength: 48)

                VStack(spacing: 6) {
                    Text("시술 중인 약을 검색해보세요")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                    Text("효능, 용법, 주의사항을 확인할 수 있어요")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
    }

    private func recentSearchRow(_ keyword: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .foregroundStyle(Color.gray)
                .font(.system(size: 14))

            Button {
                viewModel.searchText = keyword
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(keyword)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.primary)
                    Text("최근 검색어")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                viewModel.removeRecentSearch(keyword)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 12))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("로딩 상태")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
            Spacer()
        }
    }

    // MARK: Results

    private func resultsView(drugs: [Drug]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("검색 결과 \(drugs.count)건 · e약은요 API")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                ForEach(drugs, id: \.itemSeq) { drug in
                    DrugResultCell(drug: drug) {
                        Task { await viewModel.selectDrug(drug) }
                    }
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
        .overlay {
            if viewModel.isDetailLoading {
                Color.black.opacity(0.12).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.4)
            }
        }
    }

    // MARK: Empty

    private var emptyView: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Text("전문의약품은 검색 안 될 수 있어요")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)

                Text("약/주사 탭에서 직접 입력하기")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AranColor.primary)
            }
            .padding(20)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    // MARK: Error

    private func errorView(message _: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Text("네트워크 연결을 확인해주세요")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.red)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await viewModel.search(keyword: viewModel.searchText) }
                } label: {
                    Text("다시 시도")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.red)
                }
            }
            .padding(20)
            .background(Color.red.opacity(0.07))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.25), lineWidth: 1))
            .padding(.horizontal, 32)
            Spacer()
        }
    }
}

// MARK: - Drug Result Cell

private struct DrugResultCell: View {
    let drug: Drug
    let onDetail: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(drug.itemName)
                .font(.system(size: 16, weight: .semibold))

            Text(drug.entpName)
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)

            if let efcy = drug.efcyQesitm {
                Text(efcy.prefix(40))
                    .font(.system(size: 12))
                    .foregroundStyle(AranColor.primary)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AranColor.primary.opacity(0.1))
                    .clipShape(Capsule())
            }

            HStack {
                Text("전문의약품")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)

                Spacer()

                Button("상세 보기", action: onDetail)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(AranColor.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
