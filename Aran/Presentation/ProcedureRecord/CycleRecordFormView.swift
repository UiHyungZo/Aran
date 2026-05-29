//
//  CycleRecordFormView.swift
//  Aran
//

import SwiftUI

struct CycleRecordFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    let initialSummary: ProcedureCycleSummary?
    @Environment(\.dismiss) private var dismiss

    @State private var cycleNumber: Int
    @State private var startDate: Date
    @State private var retrievalCount: Int
    @State private var fertilizedCount: Int
    @State private var frozenCount: Int
    @State private var embryoRecords: [EmbryoRecord]

    @State private var draftStage: EmbryoStage = .blastocystDay5
    @State private var draftSimpleGrade: EmbryoSimpleGrade = .unknown
    @State private var draftRawGrade: String = ""
    @State private var draftIsFrozen: Bool = true

    @State private var includesTransfer = false
    @State private var transferDate = Date()
    @State private var transferGrade: String = ""
    @State private var transferCount = 1
    @State private var transferType: TransferType = .frozen

    init(viewModel: ProcedureRecordViewModel, initialSummary: ProcedureCycleSummary? = nil) {
        self.viewModel = viewModel
        self.initialSummary = initialSummary
        _cycleNumber = State(initialValue: initialSummary?.cycleNumber ?? 1)
        _startDate = State(initialValue: initialSummary?.startDate ?? Date())
        _retrievalCount = State(initialValue: initialSummary?.retrievalCount ?? 0)
        _fertilizedCount = State(initialValue: initialSummary?.fertilizedCount ?? 0)
        _frozenCount = State(initialValue: initialSummary?.frozenCount ?? 0)
        _embryoRecords = State(initialValue: initialSummary?.embryoRecords ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("차수 정보") {
                    Stepper("\(cycleNumber)차", value: $cycleNumber, in: 1...20)
                    DatePicker("시작일", selection: $startDate, in: ...Date(), displayedComponents: .date)
                }

                Section("채취") {
                    Stepper("채취 \(retrievalCount)개", value: $retrievalCount, in: 0...50)
                }

                Section("채취 상세") {
                    Stepper("수정 \(fertilizedCount)개", value: $fertilizedCount, in: 0...retrievalCount)
                    Stepper("동결 \(frozenCount)개", value: $frozenCount, in: 0...fertilizedCount)
                }

                Section {
                    LabeledContent("배아 단계") {
                        EmbryoStageToggle(selection: $draftStage)
                    }
                    LabeledContent("간편 등급") {
                        EmbryoSimpleGradeChips(selection: $draftSimpleGrade)
                    }
                    TextField("원본 기록 (예: 4AA, 8세포)", text: $draftRawGrade)
                    Toggle("동결 배아", isOn: $draftIsFrozen)
                    Button {
                        appendDraftEmbryo()
                    } label: {
                        Label("배아 추가", systemImage: "plus.circle.fill")
                    }
                    .foregroundStyle(AranColor.dotTransfer)
                } header: {
                    Text("배아 기록")
                }

                if !embryoRecords.isEmpty {
                    Section("추가된 배아") {
                        ForEach(embryoRecords) { embryo in
                            EmbryoRecordRow(embryo: embryo)
                        }
                        .onDelete { indexSet in
                            embryoRecords.remove(atOffsets: indexSet)
                        }
                    }
                }

                Section {
                    Toggle("이식도 함께 기록", isOn: $includesTransfer)
                    if includesTransfer {
                        DatePicker("이식일", selection: $transferDate, in: ...Date(), displayedComponents: .date)
                        TextField("배아 등급 (예: 4AA)", text: $transferGrade)
                        Stepper("이식 \(transferCount)개", value: $transferCount, in: 1...5)
                        LabeledContent("종류") {
                            HStack(spacing: 8) {
                                ForEach([TransferType.frozen, .fresh], id: \.self) { type in
                                    let isOn = transferType == type
                                    Button(type.rawValue) { transferType = type }
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                                            in: Capsule()
                                        )
                                        .foregroundStyle(isOn ? .white : .primary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("이식")
                }
            }
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .onChange(of: retrievalCount) { _, newValue in
                fertilizedCount = min(fertilizedCount, newValue)
                frozenCount = min(frozenCount, fertilizedCount)
            }
            .onChange(of: fertilizedCount) { _, newValue in
                frozenCount = min(frozenCount, newValue)
            }
            .navigationTitle(initialSummary != nil ? "\(cycleNumber)차 편집" : "채취/배아 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            if initialSummary != nil {
                                await viewModel.updateCycleRecord(
                                    cycleNumber: cycleNumber,
                                    startDate: startDate,
                                    retrievalCount: retrievalCount,
                                    fertilizedCount: fertilizedCount,
                                    frozenCount: frozenCount,
                                    embryoRecords: embryoRecords
                                )
                            } else {
                                await viewModel.saveCycleRecord(
                                    cycleNumber: cycleNumber,
                                    startDate: startDate,
                                    retrievalCount: retrievalCount,
                                    fertilizedCount: fertilizedCount,
                                    frozenCount: frozenCount,
                                    embryoRecords: embryoRecords
                                )
                            }
                            if includesTransfer {
                                await viewModel.saveTransfer(
                                    cycleNumber: cycleNumber,
                                    date: transferDate,
                                    embryoGrade: transferGrade,
                                    embryoCount: transferCount,
                                    transferType: transferType
                                )
                            }
                            dismiss()
                        }
                    }
                    .disabled(retrievalCount == 0)
                }
            }
        }
    }

    private func appendDraftEmbryo() {
        let cycleId = initialSummary?.cycleRecordId ?? UUID()
        let embryo = EmbryoRecord(
            id: UUID(),
            cycleId: cycleId,
            stage: draftStage,
            simpleGrade: draftSimpleGrade,
            rawGrade: draftRawGrade.isEmpty ? nil : draftRawGrade,
            isFrozen: draftIsFrozen,
            memo: nil
        )
        embryoRecords.append(embryo)
        resetDraft()
    }

    private func resetDraft() {
        draftStage = .blastocystDay5
        draftSimpleGrade = .unknown
        draftRawGrade = ""
        draftIsFrozen = true
    }
}

private struct EmbryoRecordRow: View {
    let embryo: EmbryoRecord

    var body: some View {
        HStack(spacing: 8) {
            Text(embryo.stage.rawValue)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(AranColor.procedureChipBackground, in: Capsule())
                .foregroundStyle(AranColor.procedureChipText)
            if embryo.simpleGrade != .unknown {
                Text(embryo.simpleGrade.rawValue)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(AranColor.dotTransfer.opacity(0.12), in: Capsule())
                    .foregroundStyle(AranColor.dotTransfer)
            }
            if let raw = embryo.rawGrade, !raw.isEmpty {
                Text(raw)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(embryo.isFrozen ? "동결" : "신선")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
