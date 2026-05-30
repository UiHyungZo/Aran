//
//  ProcedurePGTFormView.swift
//  Aran
//

import SwiftUI

struct ProcedurePGTFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    let cycleRecordId: UUID
    var maxCount: Int = Int.max

    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: PGTType = .pgtA
    @State private var testDate = Date()
    @State private var normalCount = 0
    @State private var abnormalCount = 0
    @State private var mosaicCount = 0
    @State private var inconclusiveCount = 0
    @State private var resultStatus: PGTResultStatus = .normal
    @State private var femaleChromosomeResult: ChromosomeResult = .normal
    @State private var maleChromosomeResult: ChromosomeResult = .normal
    @State private var implantationTestType: ImplantationTestType = .era
    @State private var implantationResult: ImplantationResult = .receptive
    @State private var recommendedTransferWindow = ""
    @State private var memo = ""
    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        !selectedType.showsEmbryoCounts || normalCount + abnormalCount + mosaicCount + inconclusiveCount > 0
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
                        Picker("결과 상태", selection: $resultStatus) {
                            ForEach(PGTResultStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
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
            .navigationTitle("검사 기록 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            let didSave = await viewModel.savePGTRecord(
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
                            if didSave {
                                dismiss()
                            }
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
