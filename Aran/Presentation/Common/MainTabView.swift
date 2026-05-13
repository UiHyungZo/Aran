//
//  MainTabView.swift
//  Aran
//
//  Created by Iker Casillas on 5/13/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {

    @State private var selectedTab: Tab = .calendar
    @Environment(\.modelContext) private var modelContext

    enum Tab: CaseIterable {
        case calendar, medication, exam, drugInfo

        var icon: String {
            switch self {
            case .calendar:   return "calendar"
            case .medication: return "pill.fill"
            case .exam:       return "waveform.path.ecg"
            case .drugInfo:   return "magnifyingglass"
            }
        }

        var label: String {
            switch self {
            case .calendar:   return "캘린더"
            case .medication: return "약/주사"
            case .exam:       return "검사"
            case .drugInfo:   return "약 정보"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .calendar:
            CalendarView(viewModel: CalendarViewModel(
                cycleRecordUseCase: CycleRecordUseCase(
                    repository: CycleRecordRepository(context: modelContext)
                )
            ))
        case .medication:
            MedicationListWrapper()
        case .exam:
            ExamListWrapper()
        case .drugInfo:
            DrugInfoView()
        }
    }
}

// MARK: - Custom Tab Bar

private struct CustomTabBar: View {

    @Binding var selectedTab: MainTabView.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                Spacer()
                TabBarItem(tab: tab, isSelected: selectedTab == tab) {
                    selectedTab = tab
                }
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 28) // safe area 보정
        .background(Color(.systemBackground))
    }
}

private struct TabBarItem: View {

    let tab: MainTabView.Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? AranColor.primary : Color.gray)
                    .padding(10)
                    .background(
                        isSelected
                            ? AranColor.primary.opacity(0.15)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12)
                    )

                Text(tab.label)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? AranColor.primary : Color.gray)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
