//
//  MainTabView.swift
//  Aran
//
//  Created by Iker Casillas on 5/13/26.
//

import SwiftUI
import AranDomain

struct MainTabView: View {
    let container: AppDIContainer
    @State private var selectedTab: Tab = .calendar
    @State private var drugToAdd: Drug?

    enum Tab: CaseIterable {
        case calendar, medication, exam, procedureRecord, drugInfo

        var icon: String {
            switch self {
            case .calendar: return "calendar"
            case .medication: return "pill.fill"
            case .exam: return "waveform.path.ecg"
            case .procedureRecord: return "chart.bar.fill"
            case .drugInfo: return "magnifyingglass"
            }
        }

        var label: String {
            switch self {
            case .calendar: return "캘린더"
            case .medication: return "약/주사"
            case .exam: return "검사"
            case .procedureRecord: return "시술 기록"
            case .drugInfo: return "약 정보"
            }
        }

        var accessibilityID: String {
            switch self {
            case .calendar: return "tab.calendar"
            case .medication: return "tab.medication"
            case .exam: return "tab.exam"
            case .procedureRecord: return "tab.procedureRecord"
            case .drugInfo: return "tab.drugInfo"
            }
        }

        var screenAccessibilityID: String {
            switch self {
            case .calendar: return "screen.calendar"
            case .medication: return "screen.medication"
            case .exam: return "screen.exam"
            case .procedureRecord: return "screen.procedureRecord"
            case .drugInfo: return "screen.drugInfo"
            }
        }

        var accentColor: Color {
            switch self {
            case .calendar: return AranColor.primary
            case .medication: return AranColor.accentMedication
            case .exam: return AranColor.accentHealth
            case .procedureRecord: return AranColor.accentProcedure
            case .drugInfo: return AranColor.accentDrug
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
        screenContent
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(selectedTab.screenAccessibilityID)
    }

    @ViewBuilder
    private var screenContent: some View {
        switch selectedTab {
        case .calendar:
            CalendarView(viewModel: container.calendarScene.makeCalendarViewModel())
        case .medication:
            MedicationListWrapper(container: container.medicationScene)
        case .exam:
            ExamListWrapper(container: container.healthRecordScene)
        case .procedureRecord:
            ProcedureRecordView(viewModel: container.procedureRecordScene.makeProcedureRecordViewModel())
        case .drugInfo:
            DrugInfoView(
                viewModel: container.drugInfoScene.makeDrugInfoViewModel(),
                onAddDrug: { drug in drugToAdd = drug }
            )
            .sheet(isPresented: Binding(
                get: { drugToAdd != nil },
                set: { if !$0 { drugToAdd = nil } }
            )) {
                if let drug = drugToAdd {
                    MedicationFormSheet(drugName: drug.itemName, container: container.medicationScene)
                }
            }
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
        .background(AranColor.surface)
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
                    .foregroundStyle(isSelected ? tab.accentColor : Color.gray)
                    .padding(10)
                    .background(
                        isSelected
                            ? tab.accentColor.opacity(0.15)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12)
                    )

                Text(tab.label)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? tab.accentColor : Color.gray)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(tab.accessibilityID)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
