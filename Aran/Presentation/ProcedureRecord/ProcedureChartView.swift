//
//  ProcedureChartView.swift
//  Aran
//

import SwiftUI
import Charts

struct ProcedureChartView: View {
    let summaries: [ProcedureCycleSummary]

    private struct ChartEntry: Identifiable {
        let id = UUID()
        let cycleNumber: Int
        let count: Int
        let category: String
    }

    private var entries: [ChartEntry] {
        summaries.flatMap { summary in
            [
                ChartEntry(
                    cycleNumber: summary.cycleNumber,
                    count: summary.retrievedCount ?? 0,
                    category: "채취"
                ),
                ChartEntry(
                    cycleNumber: summary.cycleNumber,
                    count: summary.transferredCount,
                    category: "이식"
                )
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("차수별 시술 흐름")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)

            Chart(entries) { entry in
                BarMark(
                    x: .value("차수", "\(entry.cycleNumber)차"),
                    y: .value("개수", entry.count)
                )
                .foregroundStyle(color(for: entry.category))
                .position(by: .value("구분", entry.category))
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
                legendItem(color: AranColor.dotRetrieval, label: "채취")
                legendItem(color: AranColor.dotTransfer, label: "이식")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
        }
    }

    private func color(for category: String) -> Color {
        category == "채취" ? AranColor.dotRetrieval : AranColor.dotTransfer
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }
}
