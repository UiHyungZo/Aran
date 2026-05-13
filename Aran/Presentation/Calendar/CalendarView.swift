import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var pageIndex: Int = 1
    @State private var calendarID: UUID = UUID()

    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            monthHeader
            TabView(selection: $pageIndex) {
                calendarPage(monthOffset: -1).tag(0)
                calendarPage(monthOffset:  0).tag(1)
                calendarPage(monthOffset: +1).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .id(calendarID)
            .onChange(of: pageIndex) { _, newValue in
                guard newValue != 1 else { return }
                viewModel.navigateMonth(by: newValue == 2 ? 1 : -1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    calendarID = UUID()
                    pageIndex = 1
                }
            }
        }
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
        .task { await viewModel.loadMonthRecords() }
    }

    private var monthHeader: some View {
        HStack {
            Button { withAnimation { pageIndex = 0 } } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(Self.monthFormatter.string(from: viewModel.currentMonth))
                .font(AranFont.title())
            Spacer()
            Button { withAnimation { pageIndex = 2 } } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func calendarPage(monthOffset: Int) -> some View {
        let month = Calendar.current.date(byAdding: .month, value: monthOffset, to: viewModel.currentMonth)!
        let isCurrent = monthOffset == 0
        VStack(spacing: 0) {
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth(for: month), id: \.self) { date in
                    if let date {
                        DayCell(
                            date: date,
                            isSelected: isCurrent && Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            events: isCurrent ? viewModel.events(for: date) : []
                        )
                        .onTapGesture { if isCurrent { viewModel.selectDate(date) } }
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 8)
            Spacer()
        }
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

    private func daysInMonth(for month: Date) -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: month)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
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
