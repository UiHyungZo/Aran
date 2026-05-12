//
//  MainTabView.swift
//  Aran
//
//  Created by Iker Casillas on 5/13/26.
//

import SwiftUI

struct MainTabView: View{
    
    @State private var selectedTab: Tab = .calendar
    @Environment(\.modelContext) private var modelContext
    
    enum Tab{
        case calendar, medication, exam, drugInfo
    }
    
    var body: some View{
        TabView(selection: $selectedTab) {
            
            // 📅 캘린더 — SwiftUI
            CalendarView(viewModel: CalendarViewModel(
                cycleRecordUseCase: CycleRecordUseCase(
                    repository: CycleRecordRepository(context: modelContext)
                )
            ))
            .tabItem { Label("캘린더", systemImage: "calendar") }
            .tag(Tab.calendar)
            
            // 💊 약/주사 — UIKit
            MedicationListWrapper()
                .tabItem { Label("약/주사", systemImage: "pill.fill") }
                .tag(Tab.medication)
            
            // 🧪 검사 — UIKit
            ExamListWrapper()
                .tabItem { Label("검사", systemImage: "waveform.path.ecg") }
                .tag(Tab.exam)
            
            // 🔍 약 정보 — SwiftUI
            DrugInfoView()
                .tabItem { Label("약 정보", systemImage: "magnifyingglass") }
                .tag(Tab.drugInfo)
        }
        .tint(AranColor.primary)
    }
    
}
