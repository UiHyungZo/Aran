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

    private var summary: ProcedureCycleSummary? {
        viewModel.cycleSummaries.first { $0.cycleNumber == cycleNumber }
    }

    // 채취 기록이 있고 수정 개수가 있을 때만 풀 검증 적용
    private var isPoolLimited: Bool {
        (summary?.cycleRecordId != nil) && (summary?.fertilizedCount ?? 0) > 0
    }

    private var frozenPool: Int { summary?.frozenCount ?? 0 }
    private var freshPool: Int { max(0, (summary?.fertilizedCount ?? 0) - (summary?.frozenCount ?? 0)) }

    private var editingRecordId: UUID? {
        if case let .edit(record) = mode { return record.id }
        return nil
    }

    // 수정 모드에서는 편집 중인 레코드를 기존 소비에서 제외
    private func existingUsed(_ type: TransferType) -> Int {
        (summary?.transferRecords ?? [])
            .filter { $0.transferType == type && $0.id != editingRecordId }
            .reduce(0) { $0 + $1.embryoCount }
    }

    private func draftUsed(_ type: TransferType) -> Int {
        rows.filter { $0.transferType == type }.reduce(0) { $0 + $1.embryoCount }
    }

    private func pool(for type: TransferType) -> Int {
        type == .frozen ? frozenPool : freshPool
    }

    // 행 입력 시 증가 가능한 최대 개수 (같은 종류의 다른 행 소비분도 차감)
    private func maxCount(forRow index: Int) -> Int {
        let type = rows[index].transferType
        let otherDrafts = rows.enumerated()
            .filter { $0.offset != index && $0.element.transferType == type }
            .reduce(0) { $0 + $1.element.embryoCount }
        return pool(for: type) - existingUsed(type) - otherDrafts
    }

    // 잔여 가능 개수 (음수면 0)
    private func remaining(for type: TransferType) -> Int {
        max(0, pool(for: type) - existingUsed(type) - draftUsed(type))
    }

    private func isExceeded(_ type: TransferType) -> Bool {
        existingUsed(type) + draftUsed(type) > pool(for: type)
    }

    private var withinPoolLimits: Bool {
        !isExceeded(.frozen) && !isExceeded(.fresh)
    }

    private var isValid: Bool {
        guard !rows.isEmpty, rows.allSatisfy({ $0.embryoCount > 0 }) else { return false }
        return isPoolLimited ? withinPoolLimits : true
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
                Section {
                    Stepper("\(cycleNumber)차", value: $cycleNumber, in: 1...20)
                        .disabled(!isEditMode)
                    DatePicker("이식일", selection: $date, in: ...Date(), displayedComponents: .date)
                } header: {
                    Text("기본 정보")
                } footer: {
                    if isPoolLimited {
                        Text("이식 가능 · 신선 \(remaining(for: .fresh))개 · 동결 \(remaining(for: .frozen))개")
                    }
                }

                ForEach(rows.indices, id: \.self) { index in
                    Section("배아 \(index + 1)") {
                        TextField("배아 등급 (예: 4AA)", text: $rows[index].embryoGrade)
                        Stepper(
                            "이식 \(rows[index].embryoCount)개",
                            value: $rows[index].embryoCount,
                            in: 1...(isPoolLimited ? max(1, maxCount(forRow: index)) : 5)
                        )
                        Picker("종류", selection: $rows[index].transferType) {
                            Text(TransferType.frozen.rawValue).tag(TransferType.frozen)
                            Text(TransferType.fresh.rawValue).tag(TransferType.fresh)
                        }
                        .pickerStyle(.segmented)

                        if isPoolLimited, isExceeded(rows[index].transferType) {
                            Text("\(rows[index].transferType.rawValue) 이식 가능 개수를 초과했어요")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
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
