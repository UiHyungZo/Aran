import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel

    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                monthHeader
                weekdayHeader
                calendarGrid
                Spacer()
            }
            .navigationTitle("캘린더")
            .sheet(isPresented: $viewModel.isDetailSheetPresented) {
                DateDetailSheet(viewModel: viewModel)
            }
            .alert("오류", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("확인") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task { await viewModel.loadMonthRecords() }
    }

    private var monthHeader: some View {
        HStack {
            Button { viewModel.navigateMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(viewModel.currentMonth, format: .dateTime.year().month())
                .font(AranFont.title())
            Spacer()
            Button { viewModel.navigateMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(AranFont.caption())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(daysInMonth(), id: \.self) { date in
                if let date {
                    DayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        events: viewModel.events(for: date)
                    )
                    .onTapGesture { viewModel.selectDate(date) }
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: viewModel.currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.currentMonth))!
        let weekdayOffset = calendar.component(.weekday, from: firstDay) - 1

        var days: [Date?] = Array(repeating: nil, count: weekdayOffset)
        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        return days
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let events: [DayEvent]

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(AranFont.body(14))
                .foregroundStyle(isToday ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? AranColor.primary : isToday ? .gray : .clear)
                )
            HStack(spacing: 2) {
                ForEach(Array(Set(events.map(\.dotColor)).prefix(3)), id: \.self) { colorName in
                    Circle()
                        .fill(Color(colorName))
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 48)
    }
}
