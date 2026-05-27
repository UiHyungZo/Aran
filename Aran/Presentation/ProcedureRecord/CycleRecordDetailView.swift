//
//  CycleRecordDetailView.swift
//  Aran
//

import SwiftUI

struct CycleRecordDetailView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    let cycleNumber: Int

    @State private var isTransferFormPresented = false
    @State private var isPGTFormPresented = false
    @State private var selectedTransfer: TransferRecord?
    @State private var transferToDelete: TransferRecord?
    @State private var pgtToDelete: PGTRecord?

    private var summary: ProcedureCycleSummary? {
        viewModel.cycleSummaries.first { $0.cycleNumber == cycleNumber }
    }

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("상세 기록을 불러오는 중")
            } else if let summary {
                overviewSection(summary: summary)
                transferSection(summary: summary)
                pgtSection(summary: summary)
                Section {
                    ProcedureChartView(entries: viewModel.chartData())
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                        .listRowBackground(Color.clear)
                }
            } else {
                Text("차수 기록을 찾을 수 없어요")
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("\(cycleNumber)차 상세")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isTransferFormPresented) {
            TransferInputFormView(viewModel: viewModel, initialCycleNumber: cycleNumber)
        }
        .sheet(isPresented: $isPGTFormPresented) {
            if let cycleRecordId = summary?.cycleRecordId {
                ProcedurePGTFormView(viewModel: viewModel, cycleRecordId: cycleRecordId)
            }
        }
        .sheet(item: $selectedTransfer) { transfer in
            TransferResultView(viewModel: viewModel, transferRecord: transfer)
        }
        .confirmationDialog(
            "이식 기록을 삭제할까요?",
            isPresented: Binding(
                get: { transferToDelete != nil },
                set: { if !$0 { transferToDelete = nil } }
            ),
            presenting: transferToDelete
        ) { transfer in
            Button("삭제", role: .destructive) {
                Task { await viewModel.deleteTransfer(id: transfer.id) }
            }
            Button("취소", role: .cancel) { }
        }
        .confirmationDialog(
            "검사 기록을 삭제할까요?",
            isPresented: Binding(
                get: { pgtToDelete != nil },
                set: { if !$0 { pgtToDelete = nil } }
            ),
            presenting: pgtToDelete
        ) { record in
            Button("삭제", role: .destructive) {
                Task { await viewModel.deletePGT(id: record.id) }
            }
            Button("취소", role: .cancel) { }
        }
        .task { await viewModel.load() }
    }

    private func overviewSection(summary: ProcedureCycleSummary) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(summary.cycleNumber)차")
                            .font(.title3.weight(.semibold))
                        Text(summary.displayStartDate, style: .date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    TransferResultBadge(result: summary.latestResult)
                }

                HStack(spacing: 10) {
                    CountPill(title: "채취", count: summary.retrievalCount)
                    CountPill(title: "수정", count: summary.fertilizedCount)
                    CountPill(title: "동결", count: summary.frozenCount)
                    CountPill(title: "이식", count: summary.transferredCount)
                    CountPill(title: "검사", count: summary.pgtRecords.count)
                }

                if !summary.embryoGrades.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(summary.embryoGrades, id: \.self) { grade in
                            Text(grade)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AranColor.procedureChipBackground, in: Capsule())
                                .foregroundStyle(AranColor.procedureChipText)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func transferSection(summary: ProcedureCycleSummary) -> some View {
        Section {
            if summary.transferRecords.isEmpty {
                Text("이식 기록이 없어요")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(summary.transferRecords) { record in
                    Button {
                        selectedTransfer = record
                    } label: {
                        TransferRow(record: record)
                    }
                    .swipeActions {
                        Button("삭제", role: .destructive) {
                            transferToDelete = record
                        }
                    }
                }
            }

            Button {
                isTransferFormPresented = true
            } label: {
                Label("이식 추가", systemImage: "plus.circle.fill")
            }
            .foregroundStyle(AranColor.dotTransfer)
        } header: {
            Text("이식 기록")
        }
    }

    private func pgtSection(summary: ProcedureCycleSummary) -> some View {
        Section {
            if summary.pgtRecords.isEmpty {
                Text("PGT / 염색체 / 반착검사 기록이 없어요")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(summary.pgtRecords) { record in
                    PGTRow(record: record)
                        .swipeActions {
                            Button("삭제", role: .destructive) {
                                pgtToDelete = record
                            }
                        }
                }
            }

            if summary.cycleRecordId == nil {
                Text("PGT 기록은 차수 추가 후 입력할 수 있어요")
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    isPGTFormPresented = true
                } label: {
                    Label("검사 추가", systemImage: "plus.circle.fill")
                }
                .foregroundStyle(AranColor.dotTransfer)
            }
        } header: {
            Text("PGT / 염색체 / 반착검사")
        }
    }
}

private struct TransferRow: View {
    let record: TransferRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                TransferResultBadge(result: record.result)
            }

            HStack(spacing: 8) {
                Text(record.transferType.rawValue)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                Text("\(record.embryoGrade)  \(record.embryoCount)개")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 3)
    }
}

private struct PGTRow: View {
    let record: PGTRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.type.rawValue)
                    .font(.body.weight(.medium))
                Spacer()
                Text(record.testDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if record.type.showsEmbryoCounts {
                HStack(spacing: 8) {
                    PGTCountChip(title: "정상", count: record.normalCount)
                    PGTCountChip(title: "이상", count: record.abnormalCount)
                    PGTCountChip(title: "모자이크", count: record.mosaicCount)
                }
            }

            if let memo = record.memo, !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}

private struct PGTCountChip: View {
    let title: String
    let count: Int

    var body: some View {
        Text("\(title) \(count)")
            .font(.caption.weight(.medium))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(AranColor.procedureChipBackground, in: Capsule())
            .foregroundStyle(AranColor.procedureChipText)
    }
}
