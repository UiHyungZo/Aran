import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var pageIndex: Int = 1
    @State private var calendarID: UUID = UUID()
    @State private var isExpanded: Bool = false
    @State private var availableHeight: CGFloat = 700

    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    private let monthHeaderH: CGFloat   = 48
    private let weekdayHeaderH: CGFloat = 28
    private let dragHandleH: CGFloat    = 21
    private let detailRatio: CGFloat    = 0.38

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f
    }()

    private static let detailDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M. d. E"
        return f
    }()

    // MARK: - 높이 계산

    private var calendarGridHeight: CGFloat {
        let detailH = isExpanded ? 0 : availableHeight * detailRatio
        let weeks = CGFloat(numberOfWeeks(for: viewModel.currentMonth))
        let minH = weeks * 44 + 4 * (weeks - 1)
        return max(minH, availableHeight - monthHeaderH - weekdayHeaderH - dragHandleH - detailH)
    }

    private var cellHeight: CGFloat {
        let weeks = CGFloat(numberOfWeeks(for: viewModel.currentMonth))
        let spacing = 4 * (weeks - 1)
        return max(44, (calendarGridHeight - spacing) / weeks)
    }

    private func numberOfWeeks(for month: Date) -> Int {
        Int(ceil(Double(daysInMonth(for: month).count) / 7.0))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            monthHeader
            weekdayHeader
            TabView(selection: $pageIndex) {
                calendarPageGrid(monthOffset: -1).tag(0)
                calendarPageGrid(monthOffset:  0).tag(1)
                calendarPageGrid(monthOffset: +1).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .id(calendarID)
            .frame(height: calendarGridHeight)
            .onChange(of: pageIndex) { _, newValue in
                guard newValue != 1 else { return }
                viewModel.navigateMonth(by: newValue == 2 ? 1 : -1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    calendarID = UUID()
                    pageIndex = 1
                }
            }

            dragHandle

            if !isExpanded {
                inlineDateDetail
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isExpanded)
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear { availableHeight = geo.size.height }
                    .onChange(of: geo.size.height) { _, h in availableHeight = h }
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

    // MARK: - 월 헤더

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

    // MARK: - 요일 헤더 (TabView 바깥, 고정)

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

    // MARK: - 드래그 핸들

    private var dragHandle: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.4))
            .frame(width: 36, height: 5)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        guard abs(value.translation.height) > abs(value.translation.width) else { return }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isExpanded = value.translation.height > 0
                        }
                    }
            )
    }

    // MARK: - 인라인 날짜 상세

    private var inlineDateDetail: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            Text(selectedDateLabel)
                .font(AranFont.body(15))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            let dayEvents = viewModel.events(for: viewModel.selectedDate)
            if dayEvents.isEmpty {
                Text("일정이 없습니다.")
                    .font(AranFont.caption())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(dayEvents.enumerated()), id: \.offset) { _, event in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(event.dotColor))
                                    .frame(width: 8, height: 8)
                                Text(eventLabel(for: event))
                                    .font(AranFont.body(14))
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture { viewModel.isDetailSheetPresented = true }
    }

    private var selectedDateLabel: String {
        Self.detailDateFormatter.string(from: viewModel.selectedDate)
    }

    private func eventLabel(for event: DayEvent) -> String {
        switch event {
        case .hospitalVisit(let note):      return "병원 방문" + (note.map { " - \($0)" } ?? "")
        case .ovulation:                    return "배란일"
        case .periodStart:                  return "생리 시작"
        case .embryoRetrieval(let n):       return "난자 채취 \(n)개"
        case .embryoTransfer(let n, let t): return "\(t.rawValue) 배아 이식 \(n)개"
        case .medication:                   return "약물 복용"
        }
    }

    // MARK: - 캘린더 그리드 (요일 헤더 제외)

    private func calendarPageGrid(monthOffset: Int) -> some View {
        let month = Calendar.current.date(byAdding: .month, value: monthOffset, to: viewModel.currentMonth)!
        let isCurrent = monthOffset == 0
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(daysInMonth(for: month).enumerated()), id: \.offset) { _, date in
                if let date {
                    DayCell(
                        date: date,
                        isSelected: isCurrent && Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        events: isCurrent ? viewModel.events(for: date) : [],
                        cellHeight: cellHeight
                    )
                    .onTapGesture {
                        if isCurrent {
                            viewModel.selectDate(date)
                            if isExpanded {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    isExpanded = false
                                }
                            }
                        }
                    }
                } else {
                    Color.clear.frame(height: cellHeight)
                }
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
    let cellHeight: CGFloat

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
        .frame(height: cellHeight)
    }
}
