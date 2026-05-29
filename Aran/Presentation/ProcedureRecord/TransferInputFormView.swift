//
//  TransferInputFormView.swift
//  Aran
//

import SwiftUI

struct TransferInputFormView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var cycleNumber: Int
    @State private var date = Date()
    @State private var rawGrade: String = ""
    @State private var embryoCount = 1
    @State private var transferType: TransferType = .frozen

    init(viewModel: ProcedureRecordViewModel, initialCycleNumber: Int = 1) {
        self.viewModel = viewModel
        _cycleNumber = State(initialValue: initialCycleNumber)
    }

    private var isValid: Bool {
        embryoCount > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    Stepper("\(cycleNumber)차", value: $cycleNumber, in: 1...20)
                    DatePicker("이식일", selection: $date, in: ...Date(), displayedComponents: .date)
                }

                Section("배아 정보") {
                    TextField("배아 등급 (예: 4AA)", text: $rawGrade)
                    Stepper("이식 \(embryoCount)개", value: $embryoCount, in: 1...5)
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
            }
            .environment(\.locale, Locale(identifier: "ko_KR"))
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
                                embryoGrade: rawGrade,
                                embryoCount: embryoCount,
                                transferType: transferType
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
