//
//  ProcedureRecordView.swift
//  Aran
//

import SwiftUI

struct ProcedureRecordView: View {
    @StateObject private var viewModel: ProcedureRecordViewModel
    @State private var cycleToDelete: ProcedureCycleSummary?

    init(viewModel: ProcedureRecordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("시술 기록을 불러오는 중")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.cycleSummaries.isEmpty {
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
                    .tint(AranColor.accentProcedure)
                    .accessibilityIdentifier("procedure.addButton")
                }
            }
            .sheet(isPresented: $viewModel.isFormPresented) {
                CycleRecordFormView(viewModel: viewModel)
            }
            .alert("오류", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("확인") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .confirmationDialog(
                "\(cycleToDelete?.cycleNumber ?? 0)차 채취 기록을 삭제할까요?",
                isPresented: Binding(
                    get: { cycleToDelete != nil },
                    set: { if !$0 { cycleToDelete = nil } }
                ),
                presenting: cycleToDelete
            ) { summary in
                Button("삭제", role: .destructive) {
                    Task { await viewModel.deleteCycleRecord(summary: summary) }
                }
                Button("취소", role: .cancel) { }
            } message: { summary in
                Text("이식 \(summary.transferredCount)건, PGT \(summary.pgtRecords.count)건을 포함한 모든 기록이 삭제됩니다.")
            }
        }
        .task { await viewModel.load() }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 46))
                .foregroundStyle(AranColor.accentProcedure.opacity(0.45))
            Text("첫 번째 차수를 기록해보세요")
                .font(.headline)
            Text("채취 기록을 먼저 추가한 뒤 이식과 검사 결과를 이어서 관리할 수 있어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("차수 추가") {
                viewModel.isFormPresented = true
            }
            .buttonStyle(.borderedProminent)
            .tint(AranColor.accentProcedure)
            .accessibilityIdentifier("procedure.empty.addButton")
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var contentView: some View {
        List {
            Section {
                ProcedureChartView(entries: viewModel.chartData())
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowBackground(Color.clear)
            }

            Section("차수별 기록") {
                ForEach(viewModel.cycleSummaries) { summary in
                    NavigationLink {
                        CycleRecordDetailView(viewModel: viewModel, cycleNumber: summary.cycleNumber)
                    } label: {
                        CycleSummaryCard(summary: summary)
                    }
                    .accessibilityIdentifier("procedure.cycle.\(summary.cycleNumber)")
                    .swipeActions(edge: .trailing) {
                        Button("삭제", role: .destructive) {
                            if summary.transferRecords.isEmpty && summary.pgtRecords.isEmpty {
                                Task { await viewModel.deleteCycleRecord(summary: summary) }
                            } else {
                                cycleToDelete = summary
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AranColor.background)
        .refreshable {
            await viewModel.load()
        }
    }
}

private struct CycleSummaryCard: View {
    let summary: ProcedureCycleSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(summary.cycleNumber)차 채취")
                        .font(.headline)
                    Text(summary.displayStartDate, style: .date)
                        .font(.caption)
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

            if summary.transferRecords.isEmpty {
                Text("상세에서 이식 기록을 추가할 수 있어요")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct CountPill: View {
    let title: String
    let count: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AranColor.accentProcedure)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AranColor.surface, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct TransferResultBadge: View {
    let result: TransferResult

    var body: some View {
        Text(result.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor, in: Capsule())
            .foregroundStyle(textColor)
    }

    private var backgroundColor: Color {
        switch result {
        case .standby: return AranColor.badgePendingBackground
        case .waiting: return AranColor.badgePendingBackground
        case .pregnant: return AranColor.badgeSuccessBackground
        case .notPregnant: return AranColor.badgeFailedBackground
        }
    }

    private var textColor: Color {
        switch result {
        case .standby: return AranColor.badgePendingText
        case .waiting: return AranColor.badgePendingText
        case .pregnant: return AranColor.badgeSuccessText
        case .notPregnant: return AranColor.badgeFailedText
        }
    }
}
