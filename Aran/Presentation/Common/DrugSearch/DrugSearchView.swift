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
    let onRegisterDrug: (_ drugName: String, _ component: String, _ dosage: String) -> Void
    let onClose: (() -> Void)?
    
    @FocusState private var isSearchFocused: Bool
    @State private var isFavoriteListPresented = false

    private var accentColor: Color {
        switch mode {
        case .browse:
            AranColor.accentDrug
        case .register:
            AranColor.accentMedication
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                /*
                if viewModel.showDebugChip {
                    debounceChip
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                */
                
                Divider()
                contentView
            }
            .safeAreaInset(edge: .bottom) {
                if mode == .register {
                    Button {
                        onRegisterDrug("", "", "")
                    } label: {
                        Text("찾는 약이 없나요? 직접 입력하기")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AranColor.accentMedication)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AranColor.surface)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("drugSearch.directInputButton")
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
                if mode == .browse {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isFavoriteListPresented = true
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.yellow)
                        }
                        .accessibilityLabel("즐겨찾기")
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { mode == .browse && viewModel.isDetailPresented },
                set: {
                    viewModel.isDetailPresented = $0
                    if !$0 {
                        viewModel.selectedDrug = nil
                        viewModel.isDetailLoading = false
                    }
                }
            )) {
                if let drug = viewModel.selectedDrug {
                    DrugDetailView(
                        drug: drug,
                        onAddDrug: onAddDrug,
                        isFavorite: viewModel.isFavorite(drug),
                        isLoadingDetail: viewModel.isDetailLoading,
                        onToggleFavorite: { viewModel.toggleFavorite(viewModel.selectedDrug ?? drug) }
                    )
                }
            }
            .navigationDestination(isPresented: $isFavoriteListPresented) {
                FavoriteDrugListView(viewModel: viewModel, onAddDrug: onAddDrug)
            }
        }
        .background(AranColor.background)
        .task { await viewModel.loadFavorites() }
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
                .foregroundStyle(viewModel.searchText.isEmpty ? Color.gray : accentColor)
            
            TextField("약 이름으로 검색하세요", text: $viewModel.searchText)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit { isSearchFocused = false }
                .accessibilityIdentifier("drugSearch.searchField")
            
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
        .background(AranColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var debounceChip: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AranColor.accentDrug)
                .frame(width: 8, height: 8)
            Text("Combine .debounce(0.3s) -> API 호출 완료")
                .font(.system(size: 12))
                .foregroundStyle(AranColor.accentDrug)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AranColor.accentDrug.opacity(0.12))
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
        .scrollContentBackground(.hidden)
        .background(AranColor.background)
        .scrollDismissesKeyboard(.never)
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("검색 중...")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
            Spacer()
        }
    }
    
    private func resultsView(drugs: [Drug]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("검색 결과 \(viewModel.totalCount)건")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                
                ForEach(Array(drugs.enumerated()), id: \.element.itemSeq) { index, drug in
                    DrugResultCell(
                        drug: drug,
                        actionTitle: mode == .browse ? "자세히 보기" : "이 약 추가하기",
                        accentColor: accentColor,
                        accessibilityID: "drugSearch.result.\(index)"
                    ) {
                        handleDrugSelection(drug)
                    }
                    Divider()
                        .padding(.horizontal, 20)
                }
                
                if viewModel.hasMorePages {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .onAppear {
                            Task { await viewModel.loadMore() }
                        }
                }
                
                Button {
                    onRegisterDrug("", "", "")
                } label: {
                    Text("직접 입력하기")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AranColor.accentMedication)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .accessibilityIdentifier("drugSearch.directInputButton")
            }
        }
        .scrollDismissesKeyboard(.immediately)
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
            .background(AranColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 32)
            Spacer()
        }
    }
    
    private func errorView(message _: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.secondary)
                
                VStack(spacing: 6) {
                    Text("검색 결과를 불러올 수 없어요")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("네트워크 연결을 확인해주세요")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                }
                .multilineTextAlignment(.center)
                
                Button {
                    Task { await viewModel.search(keyword: viewModel.searchText) }
                } label: {
                    Text("다시 시도")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 11)
                        .background(AranColor.accentDrug)
                        .clipShape(Capsule())
                }
                
                VStack(spacing: 4) {
                    Text("검색이 안 되나요?")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                    Button {
                        onRegisterDrug("", "", "")
                    } label: {
                        Text("직접 입력하기")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AranColor.accentDrug)
                    }
                    .accessibilityIdentifier("drugSearch.directInputButton")
                }
            }
            .padding(.horizontal, 40)
            Spacer()
        }
    }
    
    private func handleDrugSelection(_ drug: Drug) {
        switch mode {
        case .browse:
            viewModel.selectDrug(drug)
        case .register:
            onRegisterDrug(drug.itemName, drug.component ?? "", "")
        }
    }
}

private struct DrugResultCell: View {
    let drug: Drug
    let actionTitle: String
    let accentColor: Color
    let accessibilityID: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                Text(drug.itemName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                let subtitle = [drug.component, drug.entpName]
                    .compactMap { $0 }
                    .joined(separator: " · ")
                Text(subtitle.isEmpty ? drug.entpName : subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)

                HStack {
                    Spacer()
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .overlay(Capsule().stroke(accentColor, lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }
}
