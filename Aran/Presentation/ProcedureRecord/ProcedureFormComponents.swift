import SwiftUI

struct CounterRow: View {
    let label: String
    @Binding var value: Int
    var unit: String = ""
    var minValue: Int = 0
    var maxValue: Int = Int.max

    init(_ label: String, _ value: Binding<Int>, unit: String = "", minValue: Int = 0, maxValue: Int = Int.max) {
        self.label = label
        self._value = value
        self.unit = unit
        self.minValue = minValue
        self.maxValue = maxValue
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.body)
            Spacer()
            HStack(spacing: 8) {
                Button {
                    if value > minValue {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemGroupedBackground), in: Circle())
                }
                .disabled(value <= minValue)

                Text("\(value)\(unit)")
                    .font(.subheadline.weight(.semibold))
                    .frame(minWidth: 50, alignment: .center)

                Button {
                    if value < maxValue {
                        value += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(AranColor.dotTransfer, in: Circle())
                }
                .disabled(value >= maxValue)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct EmbryoStageToggle: View {
    @Binding var selection: EmbryoStage

    var body: some View {
        HStack(spacing: 8) {
            ForEach(EmbryoStage.allCases, id: \.self) { stage in
                let isOn = selection == stage
                Button(stage.rawValue) { selection = stage }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                        in: Capsule()
                    )
                    .foregroundStyle(isOn ? .white : .primary)
            }
        }
    }
}

struct EmbryoSimpleGradeChips: View {
    @Binding var selection: EmbryoSimpleGrade
    private let options: [EmbryoSimpleGrade] = [.high, .midHigh, .medium, .midLow, .low]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { grade in
                let isOn = selection == grade
                Button(grade.rawValue) { selection = grade }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                        in: Capsule()
                    )
                    .foregroundStyle(isOn ? .white : .primary)
            }
        }
    }
}

struct TransferResultChips: View {
    @Binding var selection: TransferResult
    private let options: [TransferResult] = [.waiting, .pregnant, .notPregnant]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                let isOn = selection == option
                Button(option.rawValue) { selection = option }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                        in: Capsule()
                    )
                    .foregroundStyle(isOn ? .white : .primary)
            }
        }
    }
}

struct PGTTypeChips: View {
    @Binding var selection: PGTType
    private let options = PGTType.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(options.prefix(2), id: \.self) { option in
                    let isOn = selection == option
                    Button(option.rawValue) { selection = option }
                        .buttonStyle(.plain)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                            in: Capsule()
                        )
                        .foregroundStyle(isOn ? .white : .primary)
                }
            }
            HStack(spacing: 8) {
                ForEach(options.dropFirst(2), id: \.self) { option in
                    let isOn = selection == option
                    Button(option.rawValue) { selection = option }
                        .buttonStyle(.plain)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                            in: Capsule()
                        )
                        .foregroundStyle(isOn ? .white : .primary)
                }
            }
        }
    }
}

struct PGTRow: View {
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
                    PGTCountChip(title: "판정불가", count: record.inconclusiveCount)
                }
            }

            if let resultSummary = record.resultSummary {
                Text(resultSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

struct PGTCountChip: View {
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

extension PGTRecord {
    var resultSummary: String? {
        switch type {
        case .pgtA, .pgtM:
            return nil
        case .chromosomeCouple:
            let female = femaleChromosomeResult?.rawValue ?? "미입력"
            let male = maleChromosomeResult?.rawValue ?? "미입력"
            return "여성 \(female) / 남성 \(male)"
        case .implantation:
            var parts: [String] = []
            if let implantationTestType { parts.append(implantationTestType.rawValue) }
            if let implantationResult { parts.append(implantationResult.rawValue) }
            if let recommendedTransferWindow, !recommendedTransferWindow.isEmpty {
                parts.append("권장 \(recommendedTransferWindow)")
            }
            return parts.isEmpty ? resultStatus.map { "결과 상태: \($0.rawValue)" } : parts.joined(separator: " · ")
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
