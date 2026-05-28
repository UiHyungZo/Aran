//
//  TransferInputFormView.swift
//  Aran
//

import SwiftUI

struct TransferInputFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var cycleNumber: Int
    @State private var date = Date()
    @State private var embryoGrade = ""
    @State private var embryoCount = 1
    @State private var transferType: TransferType = .frozen
    @FocusState private var isFocused: Bool

    init(viewModel: ProcedureRecordViewModel, initialCycleNumber: Int = 1) {
        self.viewModel = viewModel
        _cycleNumber = State(initialValue: initialCycleNumber)
    }

    private var isValid: Bool {
        !embryoGrade.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && embryoCount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    Stepper("\(cycleNumber)차", value: $cycleNumber, in: 1...20)
                    DatePicker("이식일", selection: $date, displayedComponents: .date)
                }

                Section("배아 정보") {
                    HStack {
                        Text("등급")
                        Spacer()
                        TextField("예: 3AA", text: $embryoGrade)
                            .focused($isFocused)
                            .multilineTextAlignment(.trailing)
                    }
                    Stepper("이식 \(embryoCount)개", value: $embryoCount, in: 1...5)

                    Picker("종류", selection: $transferType) {
                        Text(TransferType.fresh.rawValue).tag(TransferType.fresh)
                        Text(TransferType.frozen.rawValue).tag(TransferType.frozen)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("이식 기록 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await viewModel.saveTransfer(
                                cycleNumber: cycleNumber,
                                date: date,
                                embryoGrade: embryoGrade.trimmingCharacters(in: .whitespacesAndNewlines),
                                embryoCount: embryoCount,
                                transferType: transferType
                            )
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") { isFocused = false }
                }
            }
        }
    }
}
