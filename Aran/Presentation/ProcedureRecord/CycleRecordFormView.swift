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

    @State private var isAddingEmbryo = false
    @State private var editingEmbryoIndex: Int?
    @State private var showDuplicateCycleAlert = false

    @State private var includesPGT = false
    @State private var pgtType: PGTType = .pgtA
    @State private var pgtTestDate = Date()
    @State private var pgtNormalCount = 0
    @State private var pgtAbnormalCount = 0
    @State private var pgtMosaicCount = 0
    @State private var pgtInconclusiveCount = 0
    @State private var pgtResultStatus: PGTResultStatus = .normal
    @State private var femaleChromosomeResult: ChromosomeResult = .normal
    @State private var maleChromosomeResult: ChromosomeResult = .normal
    @State private var implantationTestType: ImplantationTestType = .era
    @State private var implantationResult: ImplantationResult = .receptive
    @State private var recommendedTransferWindow = ""
    @State private var pgtMemo = ""

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

    private var hasInvalidPGTEmbryoResult: Bool {
        includesPGT
            && pgtType.showsEmbryoCounts
            && pgtNormalCount + pgtAbnormalCount + pgtMosaicCount + pgtInconclusiveCount == 0
    }

    private var isSaveDisabled: Bool {
        retrievalCount == 0 || hasInvalidPGTEmbryoResult
    }

    var body: some View {
        NavigationStack {
            contentView
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionRetrievalInfo
                sectionEmbryoRecords
                if initialSummary == nil {
                    sectionPGT
                }
                sectionTransfer
                saveButto
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(initialSummary != nil ? "\(cycleNumber)차 편집" : "채취/배아 기록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") { dismiss() }
            }
        }
        .sheet(isPresented: $isAddingEmbryo) {
            EmbryoFormSheet(
                cycleRecordId: initialSummary?.cycleRecordId ?? UUID(),
                embryoRecords: $embryoRecords,
                frozenCount: $frozenCount,
                editingIndex: nil,
                retrievalCount: retrievalCount,
                fertilizedCount: fertilizedCount,
                cycleNumber: cycleNumber
            )
        }
        .sheet(isPresented: Binding(
            get: { editingEmbryoIndex != nil },
            set: { if !$0 { editingEmbryoIndex = nil } }
        )) {
            if let idx = editingEmbryoIndex {
                EmbryoFormSheet(
                    cycleRecordId: initialSummary?.cycleRecordId ?? UUID(),
                    embryoRecords: $embryoRecords,
                    frozenCount: $frozenCount,
                    editingIndex: idx,
                    retrievalCount: retrievalCount,
                    fertilizedCount: fertilizedCount,
                    cycleNumber: cycleNumber
                )
            }
        }
        .alert("이미 존재하는 차수입니다", isPresented: $showDuplicateCycleAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("\(cycleNumber)차 채취 기록이 이미 있습니다. 다른 차수를 선택해주세요.")
        }
        .onChange(of: retrievalCount) { _, newValue in
            fertilizedCount = min(fertilizedCount, newValue)
            frozenCount = min(frozenCount, fertilizedCount)
        }
        .onChange(of: fertilizedCount) { _, newValue in
            frozenCount = min(frozenCount, newValue)
        }
    }

    private var sectionRetrievalInfo: some View {
        VStack(spacing: 0) {
            SectionHeader("채취 정보")
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Text("채취일")
                        .font(.body)
                    Spacer()
                    DatePicker("", selection: $startDate, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)

                Divider().padding(.horizontal, 16)

                CounterRow("차수", $cycleNumber, unit: "차", minValue: 1)

                Divider().padding(.horizontal, 16)

                CounterRow("채취 개수", $retrievalCount, unit: "개")

                Divider().padding(.horizontal, 16)

                CounterRow("수정 개수", $fertilizedCount, unit: "개", maxValue: retrievalCount)

                Divider().padding(.horizontal, 16)

                CounterRow("동결 개수", $frozenCount, unit: "개", maxValue: fertilizedCount)
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
        }
    }

    private var sectionEmbryoRecords: some View {
        VStack(spacing: 0) {
            SectionHeader("배아 기록")
            if embryoRecords.isEmpty {
                VStack(spacing: 12) {
                    Text("추가된 배아가 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button {
                        isAddingEmbryo = true
                    } label: {
                        Label("배아 추가", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AranColor.dotTransfer)
                    }
                    .disabled(fertilizedCount == 0)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(embryoRecords.enumerated()), id: \.element.id) { index, embryo in
                        if index > 0 {
                            Divider().padding(.horizontal, 16)
                        }
                        EmbryoRecordRow(embryo: embryo) {
                            editingEmbryoIndex = index
                        } onDelete: {
                            embryoRecords.remove(at: index)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    Divider().padding(.horizontal, 16)
                    Button {
                        isAddingEmbryo = true
                    } label: {
                        Label("배아 추가", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AranColor.dotTransfer)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .disabled(embryoRecords.count >= fertilizedCount || fertilizedCount == 0)
                }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var sectionPGT: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                SectionHeader("PGT / 염색체 기록")
                Spacer()
                Toggle("", isOn: $includesPGT)
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if includesPGT {
                Divider().padding(.horizontal, 16)
                VStack(spacing: 12) {
                    PGTTypeChips(selection: $pgtType)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    if pgtType.showsEmbryoCounts {
                        Divider().padding(.horizontal, 16)
                        pickerRow("결과 상태", selection: $pgtResultStatus)
                        Divider().padding(.horizontal, 16)
                        CounterRow("정상", $pgtNormalCount, unit: "개",
                                   maxValue: max(0, fertilizedCount - pgtAbnormalCount - pgtMosaicCount - pgtInconclusiveCount))
                        Divider().padding(.horizontal, 16)
                        CounterRow("이상", $pgtAbnormalCount, unit: "개",
                                   maxValue: max(0, fertilizedCount - pgtNormalCount - pgtMosaicCount - pgtInconclusiveCount))
                        Divider().padding(.horizontal, 16)
                        CounterRow("모자이크", $pgtMosaicCount, unit: "개",
                                   maxValue: max(0, fertilizedCount - pgtNormalCount - pgtAbnormalCount - pgtInconclusiveCount))
                        Divider().padding(.horizontal, 16)
                        CounterRow("판정불가", $pgtInconclusiveCount, unit: "개",
                                   maxValue: max(0, fertilizedCount - pgtNormalCount - pgtAbnormalCount - pgtMosaicCount))

                        if hasInvalidPGTEmbryoResult {
                            Text("최소 1개 이상의 배아 결과를 입력해주세요.")
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                        }
                    } else if pgtType == .chromosomeCouple {
                        Divider().padding(.horizontal, 16)
                        pickerRow("결과 상태", selection: $pgtResultStatus)
                        Divider().padding(.horizontal, 16)
                        pickerRow("여성", selection: $femaleChromosomeResult)
                        Divider().padding(.horizontal, 16)
                        pickerRow("남성", selection: $maleChromosomeResult)
                    } else if pgtType == .implantation {
                        Divider().padding(.horizontal, 16)
                        pickerRow("검사 종류", selection: $implantationTestType)
                        Divider().padding(.horizontal, 16)
                        pickerRow("결과", selection: $implantationResult)
                        Divider().padding(.horizontal, 16)
                        pickerRow("결과 상태", selection: $pgtResultStatus)
                        Divider().padding(.horizontal, 16)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("권장 이식 창")
                                .font(.body)
                            TextField("예: P+5 6시간", text: $recommendedTransferWindow)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }

                    Divider().padding(.horizontal, 16)

                    HStack(spacing: 12) {
                        Text("검사일")
                            .font(.body)
                        Spacer()
                        DatePicker("", selection: $pgtTestDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)

                    Divider().padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("메모")
                            .font(.body)
                        TextField("선택", text: $pgtMemo, axis: .vertical)
                            .font(.body)
                            .padding(8)
                            .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 6))
                            .frame(minHeight: 60, alignment: .topLeading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            } else {
                Color(.secondarySystemGroupedBackground)
                    .frame(height: 0)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func pickerRow<T>(
        _ title: String,
        selection: Binding<T>
    ) -> some View where T: CaseIterable & Hashable & RawRepresentable, T.RawValue == String {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
            Spacer()
            Picker(title, selection: selection) {
                ForEach(Array(T.allCases), id: \.self) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .labelsHidden()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    private var sectionTransfer: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                SectionHeader("이식")
                Spacer()
                Toggle("", isOn: $includesTransfer)
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if includesTransfer {
                Divider().padding(.horizontal, 16)
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text("이식일")
                            .font(.body)
                        Spacer()
                        DatePicker("", selection: $transferDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)

                    Divider().padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("배아 등급")
                            .font(.body)
                        TextField("간편등급", text: $transferGrade)
                            .font(.body)
                            .padding(8)
                            .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    Divider().padding(.horizontal, 16)

                    CounterRow("이식 개수", $transferCount, unit: "개", minValue: 1, maxValue: fertilizedCount)

                    Divider().padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        Text("종류")
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            } else {
                Color(.secondarySystemGroupedBackground)
                    .frame(height: 0)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var saveButto: some View {
        Button {
            Task {
                if initialSummary == nil && viewModel.cycleRecords.contains(where: { $0.cycleNumber == cycleNumber }) {
                    showDuplicateCycleAlert = true
                    return
                }

                let didSaveCycle: Bool
                if initialSummary != nil {
                    didSaveCycle = await viewModel.updateCycleRecord(
                        cycleNumber: cycleNumber,
                        startDate: startDate,
                        retrievalCount: retrievalCount,
                        fertilizedCount: fertilizedCount,
                        frozenCount: frozenCount,
                        embryoRecords: embryoRecords
                    )
                } else {
                    didSaveCycle = await viewModel.saveCycleRecord(
                        cycleNumber: cycleNumber,
                        startDate: startDate,
                        retrievalCount: retrievalCount,
                        fertilizedCount: fertilizedCount,
                        frozenCount: frozenCount,
                        embryoRecords: embryoRecords
                    )
                }
                guard didSaveCycle else { return }

                if includesTransfer {
                    let didSaveTransfer = await viewModel.saveTransfer(
                        cycleNumber: cycleNumber,
                        date: transferDate,
                        embryoGrade: transferGrade,
                        embryoCount: transferCount,
                        transferType: transferType
                    )
                    guard didSaveTransfer else { return }
                }

                if includesPGT && initialSummary == nil {
                    guard let cycleId = viewModel.cycleRecords.first(where: { $0.cycleNumber == cycleNumber })?.id else {
                        viewModel.errorMessage = "PGT를 저장할 차수 기록을 찾을 수 없습니다."
                        return
                    }
                    let didSavePGT = await viewModel.savePGTRecord(
                        cycleRecordId: cycleId,
                        testDate: pgtTestDate,
                        type: pgtType,
                        normalCount: pgtNormalCount,
                        abnormalCount: pgtAbnormalCount,
                        mosaicCount: pgtMosaicCount,
                        inconclusiveCount: pgtInconclusiveCount,
                        resultStatus: pgtResultStatus,
                        femaleChromosomeResult: femaleChromosomeResult,
                        maleChromosomeResult: maleChromosomeResult,
                        implantationTestType: implantationTestType,
                        implantationResult: implantationResult,
                        recommendedTransferWindow: recommendedTransferWindow,
                        memo: pgtMemo.isEmpty ? nil : pgtMemo
                    )
                    guard didSavePGT else { return }
                }

                dismiss()
            }
        } label: {
            Text("저장")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    isSaveDisabled ? Color(.systemGray4) : AranColor.dotTransfer,
                    in: RoundedRectangle(cornerRadius: 8)
                )
                .foregroundStyle(.white)
        }
        .disabled(isSaveDisabled)
    }
}

private struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)
    }
}

private struct EmbryoFormSheet: View {
    let cycleRecordId: UUID
    @Binding var embryoRecords: [EmbryoRecord]
    @Binding var frozenCount: Int
    let editingIndex: Int?
    let retrievalCount: Int
    let fertilizedCount: Int
    let cycleNumber: Int

    @Environment(\.dismiss) private var dismiss
    @State private var stage: EmbryoStage
    @State private var simpleGrade: EmbryoSimpleGrade
    @State private var rawGrade: String
    @State private var isFrozen: Bool
    @State private var addQuantity: Int
    @State private var addedCount = 0

    init(
        cycleRecordId: UUID,
        embryoRecords: Binding<[EmbryoRecord]>,
        frozenCount: Binding<Int>,
        editingIndex: Int?,
        retrievalCount: Int,
        fertilizedCount: Int,
        cycleNumber: Int
    ) {
        self.cycleRecordId = cycleRecordId
        self._embryoRecords = embryoRecords
        self._frozenCount = frozenCount
        self.editingIndex = editingIndex
        self.retrievalCount = retrievalCount
        self.fertilizedCount = fertilizedCount
        self.cycleNumber = cycleNumber

        if let idx = editingIndex, idx < embryoRecords.wrappedValue.count {
            let existing = embryoRecords.wrappedValue[idx]
            _stage = State(initialValue: existing.stage)
            _simpleGrade = State(initialValue: existing.simpleGrade)
            _rawGrade = State(initialValue: existing.rawGrade ?? "")
            _isFrozen = State(initialValue: existing.isFrozen)
            _addQuantity = State(initialValue: 1)
        } else {
            _stage = State(initialValue: .blastocystDay5)
            _simpleGrade = State(initialValue: .unknown)
            _rawGrade = State(initialValue: "")
            _isFrozen = State(initialValue: false)
            _addQuantity = State(initialValue: 1)
        }
    }

    private var isEditing: Bool { editingIndex != nil }
    private var remainingEmbryoSlots: Int { max(0, fertilizedCount - embryoRecords.count) }
    private var currentEditingEmbryoIsFrozen: Bool {
        guard let editingIndex, embryoRecords.indices.contains(editingIndex) else { return false }
        return embryoRecords[editingIndex].isFrozen
    }
    private var frozenEmbryoCountExcludingEditing: Int {
        let frozenCountAll = embryoRecords.reduce(0) { $0 + ($1.isFrozen ? 1 : 0) }
        guard isEditing, currentEditingEmbryoIsFrozen else { return frozenCountAll }
        return max(0, frozenCountAll - 1)
    }
    private var remainingFrozenSlots: Int { max(0, frozenCount - frozenEmbryoCountExcludingEditing) }
    private var isFrozenTypeDisabled: Bool { frozenCount == 0 }
    private var selectedTypeRemainingSlots: Int {
        if isFrozen {
            return min(remainingEmbryoSlots, remainingFrozenSlots)
        }
        return remainingEmbryoSlots
    }
    private var maxAddQuantity: Int { max(1, selectedTypeRemainingSlots) }
    private var isAddDisabled: Bool {
        if isEditing {
            return isFrozen && remainingFrozenSlots == 0
        }
        return selectedTypeRemainingSlots == 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        SectionHeader("차수 정보 (참고)")
                        VStack(spacing: 12) {
                            HStack {
                                Text("차수")
                                Spacer()
                                Text("\(cycleNumber)차")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(12)

                            Divider().padding(.horizontal, 12)

                            HStack {
                                Text("채취 개수")
                                Spacer()
                                Text("\(retrievalCount)개")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(12)

                            Divider().padding(.horizontal, 12)

                            HStack {
                                Text("수정 개수")
                                Spacer()
                                Text("\(fertilizedCount)개")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(12)

                            Divider().padding(.horizontal, 12)

                            HStack {
                                Text("동결 개수")
                                Spacer()
                                Text("\(frozenCount)개")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(12)
                        }
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(spacing: 0) {
                        SectionHeader("배아 정보")
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("배아 단계")
                                    .font(.body.weight(.semibold))
                                EmbryoStageToggle(selection: $stage)
                            }
                            .padding(12)

                            Divider().padding(.horizontal, 12)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("간편 등급")
                                    .font(.body.weight(.semibold))
                                EmbryoSimpleGradeChips(selection: $simpleGrade)
                            }
                            .padding(12)

                            Divider().padding(.horizontal, 12)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("원본 기록")
                                    .font(.body.weight(.semibold))
                                TextField("예: 4AA / 8세포", text: $rawGrade)
                                    .font(.body)
                                    .padding(8)
                                    .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 6))
                            }
                            .padding(12)

                            Divider().padding(.horizontal, 12)

                            VStack(spacing: 8) {
                                Text("종류")
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack(spacing: 8) {
                                    ForEach([false, true], id: \.self) { isFrozenOption in
                                        let isOn = isFrozen == isFrozenOption
                                        let isDisabled = isFrozenOption && isFrozenTypeDisabled
                                        Button(isFrozenOption ? "동결 배아" : "신선 배아") { isFrozen = isFrozenOption }
                                            .font(.subheadline.weight(.semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                                                in: Capsule()
                                            )
                                            .foregroundStyle(isOn ? .white : .primary)
                                            .opacity(isDisabled ? 0.45 : 1)
                                            .disabled(isDisabled)
                                    }
                                }
                            }
                            .padding(12)

                            if !isEditing {
                                Divider().padding(.horizontal, 12)

                                HStack {
                                    Text("추가 개수")
                                        .font(.body.weight(.semibold))
                                    Spacer()
                                    Stepper(value: $addQuantity, in: 1...maxAddQuantity) {
                                        Text("\(addQuantity)개")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                }
                                .padding(12)
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                    }

                    if !isEditing && addedCount > 0 {
                        Text("\(addedCount)개 추가됨")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AranColor.dotTransfer)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Button {
                        if isEditing, let idx = editingIndex {
                            embryoRecords[idx].stage = stage
                            embryoRecords[idx].simpleGrade = simpleGrade
                            embryoRecords[idx].rawGrade = rawGrade.isEmpty ? nil : rawGrade
                            embryoRecords[idx].isFrozen = isFrozen
                            dismiss()
                        } else {
                            let quantityToAdd = min(addQuantity, selectedTypeRemainingSlots)
                            guard quantityToAdd > 0 else { return }

                            let recordsToAdd = (0..<quantityToAdd).map { _ in
                                EmbryoRecord(
                                    id: UUID(),
                                    cycleId: cycleRecordId,
                                    stage: stage,
                                    simpleGrade: simpleGrade,
                                    rawGrade: rawGrade.isEmpty ? nil : rawGrade,
                                    isFrozen: isFrozen,
                                    memo: nil
                                )
                            }
                            embryoRecords.append(contentsOf: recordsToAdd)
                            dismiss()
                        }
                    } label: {
                        Text(isEditing ? "수정" : "추가")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                isAddDisabled ? Color(.systemGray4) : AranColor.dotTransfer,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .foregroundStyle(.white)
                    }
                    .disabled(isAddDisabled)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "배아 수정" : "배아 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEditing ? "취소" : "완료") { dismiss() }
                }
            }
            .onChange(of: isFrozen) { _, _ in
                addQuantity = min(addQuantity, maxAddQuantity)
            }
            .onChange(of: frozenCount) { _, newValue in
                if newValue == 0, isFrozen {
                    isFrozen = false
                }
                addQuantity = min(addQuantity, maxAddQuantity)
            }
        }
    }
}

private struct EmbryoRecordRow: View {
    let embryo: EmbryoRecord
    let onEdit: () -> Void
    let onDelete: () -> Void

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
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.leading, 8)
            }
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }
}
