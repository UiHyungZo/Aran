//
//  ProcedureChartView.swift
//  Aran
//

import SwiftUI
import Charts

struct ProcedureChartView: View {
    let records: [TransferRecord]

    private struct ChartEntry: Identifiable {
        let id = UUID()
        let cycleNumber: Int
        let embryoCount: Int
        let result: TransferResult
    }

    private var entries: [ChartEntry] {
        records.map {
            ChartEntry(cycleNumber: $0.cycleNumber, embryoCount: $0.embryoCount, result: $0.result)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("차수별 이식 기록")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)

            Chart(entries) { entry in
                BarMark(
                    x: .value("차수", "\(entry.cycleNumber)차"),
                    y: .value("이식 개수", entry.embryoCount)
                )
                .foregroundStyle(barColor(for: entry.result))
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 1)) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 160)
            .padding(.horizontal, 16)

            HStack(spacing: 16) {
                legendItem(color: AranColor.dotTransfer, label: "성공")
                legendItem(color: .orange, label: "대기")
                legendItem(color: .secondary, label: "실패")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
        }
    }

    private func barColor(for result: TransferResult) -> Color {
        switch result {
        case .success: return AranColor.dotTransfer
        case .pending: return .orange
        case .failed: return Color(.systemGray3)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }
}
