//
//  ProcedureRecordView.swift
//  Aran
//

import SwiftUI

struct ProcedureRecordView: View {
    @StateObject private var viewModel: ProcedureRecordViewModel

    init(viewModel: ProcedureRecordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.transferRecords.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("시술 기록")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isFormPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(AranColor.dotTransfer)
                }
            }
            .sheet(isPresented: $viewModel.isFormPresented) {
                TransferInputFormView(viewModel: viewModel)
            }
            .alert("오류", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("확인") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task { await viewModel.load() }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundStyle(AranColor.dotTransfer.opacity(0.4))
            Text("기록된 시술이 없어요")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("+ 버튼으로 이식 기록을 추가해보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("이식 기록 추가") {
                viewModel.isFormPresented = true
            }
            .buttonStyle(.borderedProminent)
            .tint(AranColor.dotTransfer)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var contentView: some View {
        List {
            Section {
                ProcedureChartView(records: viewModel.transferRecords)
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.sortedCycleNumbers, id: \.self) { cycleNumber in
                Section("\(cycleNumber)차 시술") {
                    ForEach(viewModel.records(for: cycleNumber)) { record in
                        TransferCycleCard(record: record)
                    }
                    .onDelete { offsets in
                        let records = viewModel.records(for: cycleNumber)
                        for offset in offsets {
                            let id = records[offset].id
                            Task { await viewModel.delete(id: id) }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - TransferCycleCard

private struct TransferCycleCard: View {
    let record: TransferRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                resultBadge
            }
            HStack(spacing: 8) {
                typeBadge
                Text("\(record.embryoGrade)  \(record.embryoCount)개")
                    .font(.body.weight(.medium))
            }
        }
        .padding(.vertical, 4)
    }

    private var resultBadge: some View {
        Text(record.result.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(resultColor.opacity(0.15), in: Capsule())
            .foregroundStyle(resultColor)
    }

    private var typeBadge: some View {
        Text(record.transferType.rawValue)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.secondary.opacity(0.12), in: Capsule())
            .foregroundStyle(.secondary)
    }

    private var resultColor: Color {
        switch record.result {
        case .success: return AranColor.dotTransfer
        case .pending: return .orange
        case .failed: return .secondary
        }
    }
}
