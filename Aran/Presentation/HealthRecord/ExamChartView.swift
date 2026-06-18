import Charts
import SwiftUI
import UIKit
import AranDomain

struct ExamChartView: View {
    let records: [HealthRecord]
    let type: String

    private struct IndexedRecord: Identifiable {
        let id: UUID
        let index: Int
        let sortKey: String
        let record: HealthRecord
        let label: String
    }

    private var displayPoints: [HealthRecord] {
        records
            .sorted { $0.recordDate < $1.recordDate }
            .suffix(10)
            .map { $0 }
    }

    private var indexedPoints: [IndexedRecord] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return displayPoints.enumerated().map { offset, record in
            let year = Calendar.current.component(.year, from: record.recordDate)
            formatter.dateFormat = year == currentYear ? "M.d" : "yy.M.d"
            return IndexedRecord(
                id: record.id,
                index: offset,
                sortKey: String(format: "%02d", offset),
                record: record,
                label: formatter.string(from: record.recordDate)
            )
        }
    }

    private var referenceRange: ClosedRange<Double>? {
        switch type {
        case HealthRecordType.fsh: return 3...10
        case HealthRecordType.amh: return 1...4
        case HealthRecordType.afc: return 5...20
        case HealthRecordType.e2: return 25...75
        case HealthRecordType.p4: return 0...1.5
        case HealthRecordType.lh: return 2...12
        default: return nil
        }
    }

    private var referenceItems: [(range: ClosedRange<Double>, xStart: String, xEnd: String)] {
        guard let r = referenceRange,
              !indexedPoints.isEmpty,
              let first = indexedPoints.first?.sortKey,
              let last = indexedPoints.last?.sortKey else { return [] }
        return [(r, first, last)]
    }

    var body: some View {
        Chart {
            ForEach(referenceItems, id: \.range.lowerBound) { item in
                RectangleMark(
                    xStart: .value("시작", item.xStart),
                    xEnd: .value("종료", item.xEnd),
                    yStart: .value("정상 하한", item.range.lowerBound),
                    yEnd: .value("정상 상한", item.range.upperBound)
                )
                .foregroundStyle(AranColor.accentHealth.opacity(0.12))

                RuleMark(y: .value("정상 하한", item.range.lowerBound))
                    .foregroundStyle(AranColor.accentHealth.opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                RuleMark(y: .value("정상 상한", item.range.upperBound))
                    .foregroundStyle(AranColor.accentHealth.opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }

            ForEach(indexedPoints) { item in
                BarMark(
                    x: .value("날짜", item.sortKey),
                    y: .value(type, item.record.value)
                )
                .foregroundStyle(AranColor.accentHealth)
            }
        }
        .chartXScale(domain: indexedPoints.map { $0.sortKey })
        .chartXAxis {
            AxisMarks(values: indexedPoints.map { $0.sortKey }) { value in
                AxisGridLine()
                if let key = value.as(String.self),
                   let item = indexedPoints.first(where: { $0.sortKey == key }) {
                    AxisValueLabel { Text(item.label).font(.caption2) }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartLegend(.hidden)
        .frame(height: 160)
        .padding(.top, 8)
        .accessibilityLabel("\(type) 수치 차트")
    }
}

final class ExamChartHostingView: UIView {
    private let hostingController = UIHostingController(
        rootView: ExamChartView(records: [], type: HealthRecordType.fsh)
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(records: [HealthRecord], type: String) {
        hostingController.rootView = ExamChartView(records: records, type: type)
    }

    private func setupUI() {
        backgroundColor = .clear
        hostingController.view.backgroundColor = .clear

        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
