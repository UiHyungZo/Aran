import SwiftUI
import AranDomain

struct DrugInfoView: View {
    @StateObject private var viewModel: DrugInfoViewModel
    let onAddDrug: (Drug) -> Void

    init(viewModel: DrugInfoViewModel, onAddDrug: @escaping (Drug) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onAddDrug = onAddDrug
    }

    var body: some View {
        DrugSearchView(
            title: "약 정보",
            mode: .browse,
            viewModel: viewModel,
            onAddDrug: onAddDrug,
            onRegisterDrug: { _, _, _ in },
            onClose: nil
        )
    }
}
