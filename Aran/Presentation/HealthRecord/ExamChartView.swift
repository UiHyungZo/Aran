import Charts
import SwiftUI
import UIKit

struct ExamChartView: View {
    let records: [HealthRecord]
    let item: TestItem

    private var points: [HealthRecord] {
        records
            .filter { $0.testItem.isNumeric }
            .sorted { $0.date < $1.date }
    }

    private var referenceRange: ClosedRange<Double>? {
        switch item {
        case .fsh: return 3...10
        case .amh: return 1...4
        case .afc: return 5...20
        case .e2: return 25...75
        case .progesterone: return 0...1.5
        case .lh: return 2...12
        case .beta_hcg, .pgt, .chromosomeCouple, .implantation:
            return nil
        }
    }

    var body: some View {
        Chart {
            if let referenceRange {
                RectangleMark(
                    xStart: .value("시작", points.first?.date ?? Date()),
                    xEnd: .value("종료", points.last?.date ?? Date()),
                    yStart: .value("정상 하한", referenceRange.lowerBound),
                    yEnd: .value("정상 상한", referenceRange.upperBound)
                )
                .foregroundStyle(AranColor.dotHealthRecord.opacity(0.12))

                RuleMark(y: .value("정상 하한", referenceRange.lowerBound))
                    .foregroundStyle(AranColor.dotHealthRecord.opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                RuleMark(y: .value("정상 상한", referenceRange.upperBound))
                    .foregroundStyle(AranColor.dotHealthRecord.opacity(0.45))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }

            ForEach(points) { record in
                LineMark(
                    x: .value("날짜", record.date),
                    y: .value(item.rawValue, record.value)
                )
                .foregroundStyle(AranColor.dotHealthRecord)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("날짜", record.date),
                    y: .value(item.rawValue, record.value)
                )
                .foregroundStyle(AranColor.dotHealthRecord)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartLegend(.hidden)
        .frame(height: 160)
        .padding(.top, 8)
        .accessibilityLabel("\(item.rawValue) 수치 차트")
    }
}

final class ExamChartHostingView: UIView {
    private let hostingController = UIHostingController(
        rootView: ExamChartView(records: [], item: .fsh)
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(records: [HealthRecord], item: TestItem) {
        hostingController.rootView = ExamChartView(records: records, item: item)
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
