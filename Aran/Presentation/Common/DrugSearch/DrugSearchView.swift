import SwiftUI

enum DrugSearchMode {
    case browse
    case register
}

struct DrugSearchView: View {
    let title: String
    let mode: DrugSearchMode
    @ObservedObject var viewModel: DrugInfoViewModel
    let onAddDrug: (Drug) -> Void
    let onRegisterDrug: (_ drugName: String, _ dosage: String) -> Void
    let onClose: (() -> Void)?

    @FocusState private var isSearchFocused: Bool

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
            .safeAreaInset(edge: .bottom) {
                if mode == .register {
                    Button {
                        onRegisterDrug("", "")
                    } label: {
                        Text("찾는 약이 없나요? 직접 입력하기")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AranColor.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.regularMaterial)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if let onClose {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("닫기", action: onClose)
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { mode == .browse && viewModel.selectedDrug != nil },
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

    private var debounceChip: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Combine .debounce(0.3s) -> API 호출 완료")
                .font(.system(size: 12))
                .foregroundStyle(Color.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var contentView: some View {
        if shouldShowRecentSearches {
            recentSearchesView
        } else {
            stateContentView
        }
    }

    private var shouldShowRecentSearches: Bool {
        isSearchFocused && viewModel.searchText.isEmpty && !viewModel.recentSearches.isEmpty
    }

    @ViewBuilder
    private var stateContentView: some View {
        switch viewModel.viewState {
        case .initial: initialView
        case .loading: loadingView
        case let .results(drugs): resultsView(drugs: drugs)
        case .empty: emptyView
        case let .error(message): errorView(message: message)
        }
    }

    private var initialView: some View {
        VStack(spacing: 6) {
            Spacer()
            Text(mode == .browse ? "시술 중인 약을 검색해보세요" : "등록할 약을 검색해보세요")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.secondary)
            Text(mode == .browse ? "효능, 용법, 주의사항을 확인할 수 있어요" : "검색 후 선택하거나 직접 입력할 수 있어요")
                .font(.system(size: 13))
                .foregroundStyle(Color.secondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private var recentSearchesView: some View {
        List {
            Section {
                ForEach(viewModel.recentSearches, id: \.self) { keyword in
                    Button {
                        viewModel.searchRecentKeyword(keyword)
                    } label: {
                        Label {
                            Text(keyword)
                                .foregroundStyle(Color.primary)
                        } icon: {
                            Image(systemName: "clock")
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.removeRecentSearch(keyword)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: viewModel.removeRecentSearch)
            } header: {
                HStack {
                    Text("최근 검색")
                    Spacer()
                    Button("전체 지우기") {
                        viewModel.clearRecentSearches()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
    }

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

    private func resultsView(drugs: [Drug]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("검색 결과 \(drugs.count)건")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                ForEach(drugs, id: \.itemSeq) { drug in
                    DrugResultCell(
                        drug: drug,
                        actionTitle: mode == .browse ? "자세히 보기" : "이 약 추가하기"
                    ) {
                        handleDrugSelection(drug)
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

    private var emptyView: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Text("검색 결과가 없어요")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.secondary)
                Text("전문의약품은 검색이 안 될 수 있어요")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 32)
            Spacer()
        }
    }

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

    private func handleDrugSelection(_ drug: Drug) {
        switch mode {
        case .browse:
            Task { await viewModel.selectDrug(drug) }
        case .register:
            onRegisterDrug(drug.itemName, "")
        }
    }
}

private struct DrugResultCell: View {
    let drug: Drug
    let actionTitle: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                Text(drug.itemName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(drug.entpName)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)

                if let efcy = drug.efcyQesitm {
                    Text(efcy.prefix(50))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }

                Text(actionTitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AranColor.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .overlay(Capsule().stroke(AranColor.primary, lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}
