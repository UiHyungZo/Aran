//
//  ProcedurePGTFormView.swift
//  Aran
//

import SwiftUI
import AranDomain

struct ProcedurePGTFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    var maxCount: Int = Int.max

    private let mode: FormMode

    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: PGTType
    @State private var testDate: Date
    @State private var normalCount: Int
    @State private var abnormalCount: Int
    @State private var mosaicCount: Int
    @State private var inconclusiveCount: Int
    @State private var resultStatus: PGTResultStatus
    @State private var femaleChromosomeResult: ChromosomeResult
    @State private var maleChromosomeResult: ChromosomeResult
    @State private var implantationTestType: ImplantationTestType
    @State private var implantationResult: ImplantationResult
    @State private var recommendedTransferWindow: String
    @State private var memo: String
    @FocusState private var isFocused: Bool

    init(viewModel: ProcedureRecordViewModel, cycleRecordId: UUID, maxCount: Int = Int.max) {
        self.viewModel = viewModel
        self.maxCount = maxCount
        mode = .add(cycleRecordId: cycleRecordId)
        _selectedType = State(initialValue: .pgtA)
        _testDate = State(initialValue: Date())
        _normalCount = State(initialValue: 0)
        _abnormalCount = State(initialValue: 0)
        _mosaicCount = State(initialValue: 0)
        _inconclusiveCount = State(initialValue: 0)
        _resultStatus = State(initialValue: .normal)
        _femaleChromosomeResult = State(initialValue: .normal)
        _maleChromosomeResult = State(initialValue: .normal)
        _implantationTestType = State(initialValue: .era)
        _implantationResult = State(initialValue: .receptive)
        _recommendedTransferWindow = State(initialValue: "")
        _memo = State(initialValue: "")
    }

    init(viewModel: ProcedureRecordViewModel, editRecord: PGTRecord, maxCount: Int = Int.max) {
        self.viewModel = viewModel
        self.maxCount = maxCount
        mode = .edit(editRecord)
        _selectedType = State(initialValue: editRecord.type)
        _testDate = State(initialValue: editRecord.testDate)
        _normalCount = State(initialValue: editRecord.normalCount)
        _abnormalCount = State(initialValue: editRecord.abnormalCount)
        _mosaicCount = State(initialValue: editRecord.mosaicCount)
        _inconclusiveCount = State(initialValue: editRecord.inconclusiveCount)
        _resultStatus = State(initialValue: editRecord.resultStatus ?? .normal)
        _femaleChromosomeResult = State(initialValue: editRecord.femaleChromosomeResult ?? .normal)
        _maleChromosomeResult = State(initialValue: editRecord.maleChromosomeResult ?? .normal)
        _implantationTestType = State(initialValue: editRecord.implantationTestType ?? .era)
        _implantationResult = State(initialValue: editRecord.implantationResult ?? .receptive)
        _recommendedTransferWindow = State(initialValue: editRecord.recommendedTransferWindow ?? "")
        _memo = State(initialValue: editRecord.memo ?? "")
    }

    private var isValid: Bool {
        !selectedType.showsEmbryoCounts || normalCount + abnormalCount + mosaicCount + inconclusiveCount > 0
    }

    private var title: String {
        switch mode {
        case .add: return "검사 기록 추가"
        case .edit: return "검사 기록 수정"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("검사 정보") {
                    PGTTypeChips(selection: $selectedType)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    DatePicker("검사일", selection: $testDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }

                if selectedType.showsEmbryoCounts {
                    Section("결과") {
                        Stepper(
                            "정상 \(normalCount)개",
                            value: $normalCount,
                            in: 0...max(normalCount, maxCount - abnormalCount - mosaicCount - inconclusiveCount)
                        )
                        Stepper(
                            "이상 \(abnormalCount)개",
                            value: $abnormalCount,
                            in: 0...max(abnormalCount, maxCount - normalCount - mosaicCount - inconclusiveCount)
                        )
                        Stepper(
                            "모자이크 \(mosaicCount)개",
                            value: $mosaicCount,
                            in: 0...max(mosaicCount, maxCount - normalCount - abnormalCount - inconclusiveCount)
                        )
                        Stepper(
                            "판정불가 \(inconclusiveCount)개",
                            value: $inconclusiveCount,
                            in: 0...max(inconclusiveCount, maxCount - normalCount - abnormalCount - mosaicCount)
                        )

                        if !isValid {
                            Text("최소 1개 이상의 배아 결과를 입력해주세요.")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                } else if selectedType == .chromosomeCouple {
                    Section("결과") {
                        Picker("결과 상태", selection: $resultStatus) {
                            ForEach(PGTResultStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        Picker("여성", selection: $femaleChromosomeResult) {
                            ForEach(ChromosomeResult.allCases, id: \.self) { result in
                                Text(result.rawValue).tag(result)
                            }
                        }
                        Picker("남성", selection: $maleChromosomeResult) {
                            ForEach(ChromosomeResult.allCases, id: \.self) { result in
                                Text(result.rawValue).tag(result)
                            }
                        }
                    }
                } else if selectedType == .implantation {
                    Section("결과") {
                        Picker("검사 종류", selection: $implantationTestType) {
                            ForEach(ImplantationTestType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        Picker("결과", selection: $implantationResult) {
                            ForEach(ImplantationResult.allCases, id: \.self) { result in
                                Text(result.rawValue).tag(result)
                            }
                        }
                        Picker("결과 상태", selection: $resultStatus) {
                            ForEach(PGTResultStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        TextField("권장 이식 창", text: $recommendedTransferWindow)
                            .focused($isFocused)
                    }
                }

                Section("메모") {
                    TextField("선택", text: $memo, axis: .vertical)
                        .focused($isFocused)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            let success: Bool
                            switch mode {
                            case let .add(cycleRecordId):
                                success = await viewModel.savePGTRecord(
                                    cycleRecordId: cycleRecordId,
                                    testDate: testDate,
                                    type: selectedType,
                                    normalCount: normalCount,
                                    abnormalCount: abnormalCount,
                                    mosaicCount: mosaicCount,
                                    inconclusiveCount: inconclusiveCount,
                                    resultStatus: resultStatus,
                                    femaleChromosomeResult: femaleChromosomeResult,
                                    maleChromosomeResult: maleChromosomeResult,
                                    implantationTestType: implantationTestType,
                                    implantationResult: implantationResult,
                                    recommendedTransferWindow: recommendedTransferWindow,
                                    memo: memo
                                )
                            case let .edit(record):
                                success = await viewModel.updatePGTRecord(
                                    id: record.id,
                                    testDate: testDate,
                                    type: selectedType,
                                    normalCount: normalCount,
                                    abnormalCount: abnormalCount,
                                    mosaicCount: mosaicCount,
                                    inconclusiveCount: inconclusiveCount,
                                    resultStatus: resultStatus,
                                    femaleChromosomeResult: femaleChromosomeResult,
                                    maleChromosomeResult: maleChromosomeResult,
                                    implantationTestType: implantationTestType,
                                    implantationResult: implantationResult,
                                    recommendedTransferWindow: recommendedTransferWindow,
                                    memo: memo
                                )
                            }
                            guard success else { return }
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

private extension ProcedurePGTFormView {
    enum FormMode {
        case add(cycleRecordId: UUID)
        case edit(PGTRecord)
    }
}
