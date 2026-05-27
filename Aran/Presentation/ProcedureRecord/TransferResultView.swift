//
//  TransferResultView.swift
//  Aran
//

import SwiftUI

struct TransferResultView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    let transferRecord: TransferRecord

    @Environment(\.dismiss) private var dismiss
    @State private var result: TransferResult
    @State private var memo: String

    init(viewModel: ProcedureRecordViewModel, transferRecord: TransferRecord) {
        self.viewModel = viewModel
        self.transferRecord = transferRecord
        _result = State(initialValue: transferRecord.result)
        _memo = State(initialValue: transferRecord.memo ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("이식 정보") {
                    LabeledContent("이식일") {
                        Text(transferRecord.date, style: .date)
                    }
                    LabeledContent("배아") {
                        Text("\(transferRecord.embryoGrade)  \(transferRecord.embryoCount)개")
                    }
                    LabeledContent("종류") {
                        Text(transferRecord.transferType.rawValue)
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

                Section("메모") {
                    TextField("추가 메모", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("이식 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
                            await viewModel.updateTransferResult(
                                id: transferRecord.id,
                                result: result,
                                memo: trimmedMemo.isEmpty ? nil : trimmedMemo
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
