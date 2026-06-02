//
//  ProcedureChartView.swift
//  Aran
//

import Charts
import SwiftUI

struct ProcedureChartView: View {
    let entries: [ProcedureChartEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("차수별 흐름")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)

            if entries.isEmpty {
                Text("차트로 표시할 기록이 없어요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(entries) { entry in
                    BarMark(
                        x: .value("차수", "\(entry.cycleNumber)차"),
                        y: .value("개수", entry.count)
                    )
                    .foregroundStyle(by: .value("항목", entry.category))
                    .position(by: .value("항목", entry.category))
                    .cornerRadius(4)
                }
                .chartForegroundStyleScale([
                    "채취": AranColor.accentProcedure.opacity(0.4),
                    "수정": AranColor.accentProcedure.opacity(0.6),
                    "동결": AranColor.accentProcedure.opacity(0.8),
                    "이식": AranColor.accentProcedure
                ])
                .chartYAxis {
                    AxisMarks(values: .stride(by: 1)) { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 180)
                .padding(.horizontal, 16)
            }
        }
    }
}
