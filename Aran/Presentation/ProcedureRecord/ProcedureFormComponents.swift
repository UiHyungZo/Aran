import SwiftUI

struct EmbryoGradeChips: View {
    @Binding var selected: [String]
    private let grades = ["A", "B", "C", "D"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(grades, id: \.self) { grade in
                let isOn = selected.contains(grade)
                Button(grade) {
                    if isOn {
                        selected.removeAll { $0 == grade }
                    } else {
                        selected.append(grade)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .frame(width: 48, height: 36)
                .background(
                    isOn ? AranColor.dotTransfer : Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 8)
                )
                .foregroundStyle(isOn ? .white : .primary)
            }
        }
    }
}

struct TransferResultChips: View {
    @Binding var selection: TransferResult
    private let options: [TransferResult] = [.pending, .success, .failed]

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
        FlowLayout(spacing: 8) {
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
