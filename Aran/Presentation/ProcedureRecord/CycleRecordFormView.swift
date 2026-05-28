//
//  CycleRecordFormView.swift
//  Aran
//

import SwiftUI

struct CycleRecordFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var cycleNumber = 1
    @State private var startDate = Date()
    @State private var retrievalCount = 0
    @State private var fertilizedCount = 0
    @State private var frozenCount = 0
    @State private var embryoGradesText = ""
    @FocusState private var isFocused: Bool

    private var embryoGrades: [String] {
        embryoGradesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("차수 정보") {
                    Stepper("\(cycleNumber)차", value: $cycleNumber, in: 1...20)
                    DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                }

                Section("채취") {
                    Stepper("채취 \(retrievalCount)개", value: $retrievalCount, in: 0...50)
                }

                Section("채취 상세") {
                    Stepper("수정 \(fertilizedCount)개", value: $fertilizedCount, in: 0...retrievalCount)
                    Stepper("동결 \(frozenCount)개", value: $frozenCount, in: 0...fertilizedCount)
                    TextField("배아 등급 예: 3AA, 4AB", text: $embryoGradesText)
                        .focused($isFocused)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: retrievalCount) { _, newValue in
                fertilizedCount = min(fertilizedCount, newValue)
                frozenCount = min(frozenCount, fertilizedCount)
            }
            .onChange(of: fertilizedCount) { _, newValue in
                frozenCount = min(frozenCount, newValue)
            }
            .navigationTitle("차수 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await viewModel.saveCycleRecord(
                                cycleNumber: cycleNumber,
                                startDate: startDate,
                                retrievalCount: retrievalCount,
                                fertilizedCount: fertilizedCount,
                                frozenCount: frozenCount,
                                embryoGrades: embryoGrades
                            )
                            dismiss()
                        }
                    }
                    .disabled(retrievalCount == 0)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") { isFocused = false }
                }
            }
        }
    }
}
