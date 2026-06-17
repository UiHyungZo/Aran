//
//  CycleRecordDetailView.swift
//  Aran
//

import SwiftUI
import AranDomain

struct CycleRecordDetailView: View {
    @ObservedObject var viewModel: ProcedureRecordViewModel
    let cycleNumber: Int

    @State private var isEditFormPresented = false
    @State private var transferToDelete: TransferRecord?
    @State private var transferToEdit: TransferRecord?
    @State private var isAddTransferPresented = false
    @State private var pgtToDelete: PGTRecord?
    @State private var pgtToEdit: PGTRecord?

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
        .scrollContentBackground(.hidden)
        .background(AranColor.background)
        .navigationTitle("\(cycleNumber)차 채취 상세")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditFormPresented) {
            if let summary {
                CycleRecordFormView(viewModel: viewModel, initialSummary: summary)
            }
        }
        .sheet(item: $transferToEdit) { record in
            TransferInputFormView(viewModel: viewModel, editRecord: record)
        }
        .sheet(isPresented: $isAddTransferPresented) {
            TransferInputFormView(viewModel: viewModel, initialCycleNumber: cycleNumber)
        }
        .sheet(item: $pgtToEdit) { record in
            ProcedurePGTFormView(viewModel: viewModel, editRecord: record,
                                 maxCount: summary.map {
                                     max(0, $0.fertilizedCount - $0.usedEmbryoCount(type: record.type, excluding: record.id))
                                 } ?? Int.max)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("편집") {
                    isEditFormPresented = true
                }
                .foregroundStyle(AranColor.accentProcedure)
            }
        }
        .task { await viewModel.load() }
    }

    private func overviewSection(summary: ProcedureCycleSummary) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(summary.cycleNumber)차 채취")
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

                if !summary.embryoRecords.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("배아 기록")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(summary.embryoRecords) { embryo in
                            HStack(spacing: 6) {
                                Text(embryo.stage.rawValue)
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(AranColor.procedureChipBackground, in: Capsule())
                                    .foregroundStyle(AranColor.procedureChipText)
                                if embryo.simpleGrade != .unknown {
                                    Text("간편 등급: \(embryo.simpleGrade.rawValue)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if let raw = embryo.rawGrade, !raw.isEmpty {
                                    Text("원본: \(raw)")
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
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func transferSection(summary: ProcedureCycleSummary) -> some View {
        Section {
            if summary.transferRecords.isEmpty {
                VStack(spacing: 4) {
                    Text("이식 기록이 없어요")
                        .foregroundStyle(.secondary)
                    Text("우측 상단 + 버튼으로 추가할 수 있어요")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            } else {
                ForEach(summary.transferRecords) { record in
                    TransferRow(record: record)
                        .contentShape(Rectangle())
                        .onTapGesture { transferToEdit = record }
                        .swipeActions {
                            Button("삭제", role: .destructive) {
                                transferToDelete = record
                            }
                        }
                }
            }
        } header: {
            HStack {
                Text("이식 기록")
                Spacer()
                Button {
                    isAddTransferPresented = true
                } label: {
                    Label("이식 추가", systemImage: "plus.circle")
                }
                .font(.caption)
                .foregroundStyle(AranColor.accentProcedure)
                .textCase(nil)
            }
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
                        .contentShape(Rectangle())
                        .onTapGesture { pgtToEdit = record }
                        .swipeActions {
                            Button("삭제", role: .destructive) {
                                pgtToDelete = record
                            }
                        }
                }
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
                    .background(AranColor.accentProcedure.opacity(0.12), in: Capsule())
                    .foregroundStyle(AranColor.accentProcedure)
                Text("\(record.embryoGrade)  \(record.embryoCount)개")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
            }

            if let memo = record.memo, !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 3)
    }
}
