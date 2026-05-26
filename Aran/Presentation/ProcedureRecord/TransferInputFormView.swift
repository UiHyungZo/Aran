//
//  TransferInputFormView.swift
//  Aran
//

import SwiftUI

struct TransferInputFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var cycleNumber = 1
    @State private var date = Date()
    @State private var embryoGrade = ""
    @State private var embryoCount = 1
    @State private var transferType: TransferType = .frozen
    @State private var result: TransferResult = .pending

    private var isValid: Bool {
        !embryoGrade.trimmingCharacters(in: .whitespaces).isEmpty && embryoCount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    Stepper("\(cycleNumber)차 시술", value: $cycleNumber, in: 1...20)
                    DatePicker("이식일", selection: $date, displayedComponents: .date)
                }

                Section("배아 정보") {
                    HStack {
                        Text("등급")
                        Spacer()
                        TextField("예: 3AA", text: $embryoGrade)
                            .multilineTextAlignment(.trailing)
                    }
                    Stepper("이식 \(embryoCount)개", value: $embryoCount, in: 1...10)

                    Picker("종류", selection: $transferType) {
                        Text(TransferType.fresh.rawValue).tag(TransferType.fresh)
                        Text(TransferType.frozen.rawValue).tag(TransferType.frozen)
                    }
                }

                Section("결과") {
                    Picker("결과", selection: $result) {
                        Text(TransferResult.pending.rawValue).tag(TransferResult.pending)
                        Text(TransferResult.success.rawValue).tag(TransferResult.success)
                        Text(TransferResult.failed.rawValue).tag(TransferResult.failed)
                    }
                    .pickerStyle(.segmented)
                }
            }
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
                                embryoGrade: embryoGrade.trimmingCharacters(in: .whitespaces),
                                embryoCount: embryoCount,
                                transferType: transferType,
                                result: result
                            )
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
