//
//  TransferInputFormView.swift
//  Aran
//

import SwiftUI

struct TransferInputFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var inputType: ProcedureInputType = .retrieval
    @State private var cycleNumber = 1
    @State private var date = Date()
    @State private var retrievedCount = 1
    @State private var embryoGrade = ""
    @State private var embryoCount = 1
    @State private var transferType: TransferType = .frozen
    @State private var result: TransferResult = .pending

    private var isValid: Bool {
        switch inputType {
        case .retrieval:
            return retrievedCount > 0
        case .transfer:
            return !embryoGrade.trimmingCharacters(in: .whitespaces).isEmpty && embryoCount > 0
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    Picker("기록 종류", selection: $inputType) {
                        ForEach(ProcedureInputType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    if inputType == .transfer {
                        Stepper("\(cycleNumber)차 시술", value: $cycleNumber, in: 1...20)
                    }

                    DatePicker(inputType.dateTitle, selection: $date, displayedComponents: .date)
                }

                if inputType == .retrieval {
                    Section("채취 정보") {
                        Stepper("채취 \(retrievedCount)개", value: $retrievedCount, in: 1...50)
                    }
                } else {
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
            }
            .navigationTitle("시술 기록 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await save()
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func save() async {
        switch inputType {
        case .retrieval:
            await viewModel.saveRetrieval(date: date, retrievedCount: retrievedCount)
        case .transfer:
            await viewModel.saveTransfer(
                cycleNumber: cycleNumber,
                date: date,
                embryoGrade: embryoGrade.trimmingCharacters(in: .whitespaces),
                embryoCount: embryoCount,
                transferType: transferType,
                result: result
            )
        }
    }
}

private enum ProcedureInputType: CaseIterable, Hashable {
    case retrieval
    case transfer

    var title: String {
        switch self {
        case .retrieval: return "채취"
        case .transfer: return "이식"
        }
    }

    var dateTitle: String {
        switch self {
        case .retrieval: return "채취일"
        case .transfer: return "이식일"
        }
    }
}
