import Charts
import SwiftUI
import UIKit

struct ExamChartView: View {
    let records: [HealthRecord]
    let type: String

    private var points: [HealthRecord] {
        records
            .sorted { $0.recordDate < $1.recordDate }
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

    var body: some View {
        Chart {
            if let referenceRange {
                RectangleMark(
                    xStart: .value("시작", points.first?.recordDate ?? Date()),
                    xEnd: .value("종료", points.last?.recordDate ?? Date()),
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
                    x: .value("날짜", record.recordDate),
                    y: .value(type, record.value)
                )
                .foregroundStyle(AranColor.dotHealthRecord)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("날짜", record.recordDate),
                    y: .value(type, record.value)
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
