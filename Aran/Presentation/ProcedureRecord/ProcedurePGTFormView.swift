//
//  ProcedurePGTFormView.swift
//  Aran
//

import SwiftUI

struct ProcedurePGTFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    let cycleRecordId: UUID

    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: PGTType = .pgtA
    @State private var testDate = Date()
    @State private var normalCount = 0
    @State private var abnormalCount = 0
    @State private var mosaicCount = 0
    @State private var memo = ""

    private var isValid: Bool {
        !selectedType.showsEmbryoCounts || normalCount + abnormalCount + mosaicCount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("검사 정보") {
                    Picker("종류", selection: $selectedType) {
                        ForEach(PGTType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    DatePicker("검사일", selection: $testDate, displayedComponents: .date)
                }

                if selectedType.showsEmbryoCounts {
                    Section("결과") {
                        Stepper("정상 \(normalCount)개", value: $normalCount, in: 0...30)
                        Stepper("이상 \(abnormalCount)개", value: $abnormalCount, in: 0...30)
                        Stepper("모자이크 \(mosaicCount)개", value: $mosaicCount, in: 0...30)
                    }
                }

                Section("메모") {
                    TextField("선택", text: $memo, axis: .vertical)
                }
            }
            .navigationTitle("검사 기록 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await viewModel.savePGTRecord(
                                cycleRecordId: cycleRecordId,
                                testDate: testDate,
                                type: selectedType,
                                normalCount: normalCount,
                                abnormalCount: abnormalCount,
                                mosaicCount: mosaicCount,
                                memo: memo
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
