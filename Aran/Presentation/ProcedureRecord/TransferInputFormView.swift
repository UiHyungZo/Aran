//
//  TransferInputFormView.swift
//  Aran
//

import SwiftUI

struct TransferInputFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    @Environment(\.dismiss) private var dismiss

    private let mode: FormMode

    @State private var cycleNumber: Int
    @State private var date: Date
    @State private var rows: [TransferDraftRow]

    init(viewModel: ProcedureRecordViewModel, initialCycleNumber: Int = 1, date: Date = Date()) {
        self.viewModel = viewModel
        mode = .add
        _cycleNumber = State(initialValue: initialCycleNumber)
        _date = State(initialValue: date)
        _rows = State(initialValue: [TransferDraftRow()])
    }

    init(viewModel: ProcedureRecordViewModel, editRecord: TransferRecord) {
        self.viewModel = viewModel
        mode = .edit(editRecord)
        _cycleNumber = State(initialValue: editRecord.cycleNumber)
        _date = State(initialValue: editRecord.date)
        _rows = State(initialValue: [TransferDraftRow(record: editRecord)])
    }

    private var isValid: Bool {
        !rows.isEmpty && rows.allSatisfy { $0.embryoCount > 0 }
    }

    private var isEditMode: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }

    private var title: String {
        isEditMode ? "이식 기록 수정" : "이식 기록 추가"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    Stepper("\(cycleNumber)차", value: $cycleNumber, in: 1...20)
                        .disabled(!isEditMode)
                    DatePicker("이식일", selection: $date, in: ...Date(), displayedComponents: .date)
                }

                ForEach(rows.indices, id: \.self) { index in
                    Section("배아 \(index + 1)") {
                        TextField("배아 등급 (예: 4AA)", text: $rows[index].embryoGrade)
                        Stepper("이식 \(rows[index].embryoCount)개", value: $rows[index].embryoCount, in: 1...5)
                        Picker("종류", selection: $rows[index].transferType) {
                            Text(TransferType.frozen.rawValue).tag(TransferType.frozen)
                            Text(TransferType.fresh.rawValue).tag(TransferType.fresh)
                        }
                        .pickerStyle(.segmented)
                        Picker("결과", selection: $rows[index].result) {
                            Text(TransferResult.waiting.rawValue).tag(TransferResult.waiting)
                            Text(TransferResult.pregnant.rawValue).tag(TransferResult.pregnant)
                            Text(TransferResult.notPregnant.rawValue).tag(TransferResult.notPregnant)
                        }
                        TextField("메모 (선택)", text: $rows[index].memo, axis: .vertical)
                            .lineLimit(1...3)

                        if !isEditMode && rows.count > 1 {
                            Button("이 배아 삭제", role: .destructive) {
                                rows.remove(at: index)
                            }
                        }
                    }
                }

                if !isEditMode {
                    Section {
                        Button {
                            rows.append(TransferDraftRow())
                        } label: {
                            Label("배아 행 추가", systemImage: "plus.circle")
                        }
                        .foregroundStyle(AranColor.dotTransfer)
                    }
                }
            }
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            guard await saveRecords() else { return }
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func saveRecords() async -> Bool {
        switch mode {
        case .add:
            for row in rows {
                let trimmedGrade = row.embryoGrade.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedMemo = row.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                let didSave = await viewModel.saveTransfer(
                    cycleNumber: cycleNumber,
                    date: date,
                    embryoGrade: trimmedGrade.isEmpty ? "미입력" : trimmedGrade,
                    embryoCount: row.embryoCount,
                    transferType: row.transferType,
                    result: row.result,
                    memo: trimmedMemo.isEmpty ? nil : trimmedMemo
                )
                guard didSave else { return false }
            }
            return true
        case let .edit(record):
            guard let row = rows.first else { return false }
            let trimmedGrade = row.embryoGrade.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedMemo = row.memo.trimmingCharacters(in: .whitespacesAndNewlines)
            return await viewModel.updateTransfer(
                id: record.id,
                cycleNumber: cycleNumber,
                date: date,
                embryoGrade: trimmedGrade.isEmpty ? "미입력" : trimmedGrade,
                embryoCount: row.embryoCount,
                transferType: row.transferType,
                result: row.result,
                memo: trimmedMemo.isEmpty ? nil : trimmedMemo
            )
        }
    }
}

private extension TransferInputFormView {
    enum FormMode {
        case add
        case edit(TransferRecord)
    }

    struct TransferDraftRow: Identifiable {
        let id = UUID()
        var embryoGrade: String = ""
        var embryoCount: Int = 1
        var transferType: TransferType = .frozen
        var result: TransferResult = .waiting
        var memo: String = ""

        init() {}

        init(record: TransferRecord) {
            embryoGrade = record.embryoGrade
            embryoCount = record.embryoCount
            transferType = record.transferType
            result = record.result
            memo = record.memo ?? ""
        }
    }
}
