import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var pageIndex: Int = 1
    @State private var calendarID: UUID = .init()
    @State private var isWeekMode: Bool = false
    @State private var isDiaryEditing: Bool = false
    @State private var diaryEmoji: String = ""
    @State private var diaryText: String = ""
    @State private var isHospitalFormPresented: Bool = false
    @State private var isMenstrualSheetPresented: Bool = false

    init(viewModel: CalendarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private let emojiOptions = ["😊", "😟", "😰", "😣", "🥰"]

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f
    }()

    private static let panelDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f
    }()

    private func numberOfWeeks(for month: Date) -> Int {
        Int(ceil(Double(daysInMonth(for: month).count) / 7.0))
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            monthHeader

            if !isWeekMode {
                weekdayHeader
            }

            if isWeekMode {
                weekOnlyRow
                    .padding(.vertical, 4)
            } else {
                GeometryReader { geo in
                    TabView(selection: $pageIndex) {
                        calendarPageGrid(monthOffset: -1, gridHeight: geo.size.height).tag(0)
                        calendarPageGrid(monthOffset: 0, gridHeight: geo.size.height).tag(1)
                        calendarPageGrid(monthOffset: +1, gridHeight: geo.size.height).tag(2)
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
                .frame(maxHeight: .infinity)
            }

            dotLegend
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

            if isWeekMode {
                dateSummaryPanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isWeekMode)
        .overlay(alignment: .bottom) {
            if isDiaryEditing {
                diaryEditPanel
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isDiaryEditing)
            }
        }
        .sheet(isPresented: $isHospitalFormPresented) {
            CalendarHospitalVisitFormSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $isMenstrualSheetPresented) {
            MenstrualCycleFormSheet(viewModel: viewModel)
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
            Button {
                guard !isWeekMode else { return }
                withAnimation { pageIndex = 0 }
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(Self.monthFormatter.string(from: viewModel.currentMonth))
                .font(AranFont.title())
            Spacer()
            Button {
                guard !isWeekMode else { return }
                withAnimation { pageIndex = 2 }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - 요일 헤더

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

    // MARK: - 색상 범례

    private var dotLegend: some View {
        HStack(spacing: 12) {
            legendItem(color: AranColor.dotHospital, label: "병원")
            legendItem(color: AranColor.dotTransfer, label: "이식일")
            legendItem(color: AranColor.dotMedication, label: "약 알림")
            legendItem(color: AranColor.dotHealthRecord, label: "검사")
            Spacer()
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(AranFont.caption()).foregroundStyle(.secondary)
        }
    }

    // MARK: - 주간 행

    private var weekOnlyRow: some View {
        let dates = weekDays(for: viewModel.selectedDate)
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                if let date {
                    DayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        events: viewModel.events(for: date),
                        hasHealthRecord: !viewModel.healthRecords(for: date).isEmpty,
                        hasMedication: !viewModel.medications(for: date).isEmpty,
                        cellHeight: 54
                    )
                    .onTapGesture {
                        if Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isWeekMode = false
                            }
                        } else {
                            viewModel.selectDate(date)
                        }
                    }
                } else {
                    Color.clear.frame(height: 54)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private func weekDays(for date: Date) -> [Date?] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        guard let weekStart = cal.date(byAdding: .day, value: -(weekday - 1), to: date)
        else { return Array(repeating: nil, count: 7) }
        return (0..<7).map { cal.date(byAdding: .day, value: $0, to: weekStart) }
    }

    // MARK: - 날짜 요약 패널

    private var dateSummaryPanel: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.clear.frame(height: 44)
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 5)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isWeekMode = false
                }
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        guard value.translation.height > 20 else { return }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isWeekMode = false
                        }
                    }
            )

            HStack {
                Text(Self.panelDateFormatter.string(from: viewModel.selectedDate))
                    .font(AranFont.body(17))
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    summaryRow(title: "병원 일정", subtitle: hospitalSubtitle, actionLabel: "추가") {
                        isHospitalFormPresented = true
                    }
                    Divider().padding(.leading, 16)

                    summaryRow(title: "복용 약", subtitle: medicationSubtitle) { }
                    Divider().padding(.leading, 16)

                    summaryRow(title: "감정 일기", subtitle: diarySubtitle, actionLabel: diaryActionLabel) {
                        loadExistingDiary()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isDiaryEditing = true
                        }
                    }
                    Divider().padding(.leading, 16)

                    summaryRow(title: "검사 수치", subtitle: healthSubtitle, actionLabel: "추가") { }
                    Divider().padding(.leading, 16)

                    summaryRow(title: "생리 시작일", subtitle: periodSubtitle) {
                        isMenstrualSheetPresented = true
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -2)
    }

    private func summaryRow(
        title: String,
        subtitle: String,
        actionLabel: String? = nil,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AranFont.body(15))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(AranFont.caption())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if let actionLabel {
                    Text(actionLabel)
                        .font(AranFont.caption())
                        .foregroundStyle(AranColor.primary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 요약 패널 서브타이틀

    private var hospitalSubtitle: String {
        let events = viewModel.events(for: viewModel.selectedDate).filter { event in
            if case .hospitalVisit = event { return true }
            return false
        }
        guard !events.isEmpty else { return "일정 없음" }
        if case let .hospitalVisit(note) = events[0] { return note ?? "내원 예정" }
        return "내원 예정"
    }

    private var medicationSubtitle: String {
        let meds = viewModel.medications(for: viewModel.selectedDate)
        guard !meds.isEmpty else { return "복용 약 없음" }
        return meds.prefix(3).map(\.drugName).joined(separator: " · ")
    }

    private var diarySubtitle: String {
        guard let diary = viewModel.selectedRecord?.diary, !diary.text.isEmpty else { return "기록 없음" }
        let prefix = diary.emoji.map { $0 + " " } ?? ""
        return prefix + diary.text
    }

    private var diaryActionLabel: String {
        viewModel.selectedRecord?.diary != nil ? "편집" : "작성"
    }

    private var healthSubtitle: String {
        let records = viewModel.healthRecords(for: viewModel.selectedDate)
        guard !records.isEmpty else { return "기록 없음" }
        return records.prefix(2)
            .map { "\($0.testItem.rawValue) \(String(format: "%.0f", $0.value))" }
            .joined(separator: " · ")
    }

    private var periodSubtitle: String {
        let hasPeriod = viewModel.events(for: viewModel.selectedDate).contains { event in
            if case .periodStart = event { return true }
            return false
        }
        return hasPeriod ? "생리 시작일로 기록됨" : "오늘로 기록하기"
    }

    // MARK: - 감정 일기 편집 패널

    private var diaryEditPanel: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)

            Text("감정 일기")
                .font(AranFont.body(17))
                .fontWeight(.semibold)
                .padding(.bottom, 20)

            Text("오늘 기분은?")
                .font(AranFont.caption())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            HStack(spacing: 12) {
                ForEach(emojiOptions, id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: 32))
                        .padding(8)
                        .background(
                            Circle().fill(
                                diaryEmoji == emoji
                                    ? AranColor.primary.opacity(0.15)
                                    : Color.clear
                            )
                        )
                        .onTapGesture {
                            diaryEmoji = diaryEmoji == emoji ? "" : emoji
                        }
                }
            }
            .padding(.vertical, 12)

            Text("오늘 하루 기록")
                .font(AranFont.caption())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 4)

            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $diaryText)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .onChange(of: diaryText) { _, new in
                        if new.count > 500 { diaryText = String(new.prefix(500)) }
                    }

                Text("\(diaryText.count) / 500")
                    .font(AranFont.caption())
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 24)
                    .padding(.bottom, 8)
            }

            Button {
                Task {
                    await viewModel.saveDiary(
                        emoji: diaryEmoji.isEmpty ? nil : diaryEmoji,
                        text: diaryText
                    )
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isDiaryEditing = false
                    }
                }
            } label: {
                Text("저장")
                    .font(AranFont.body(16))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        diaryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.gray.opacity(0.3)
                            : Color.black
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(diaryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: -4)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    guard value.translation.height > 60 else { return }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        isDiaryEditing = false
                    }
                }
        )
    }

    private func loadExistingDiary() {
        if let diary = viewModel.selectedRecord?.diary {
            diaryEmoji = diary.emoji ?? ""
            diaryText = diary.text
        } else {
            diaryEmoji = ""
            diaryText = ""
        }
    }

    // MARK: - 캘린더 그리드

    private func calendarPageGrid(monthOffset: Int, gridHeight: CGFloat) -> some View {
        let month = Calendar.current.date(byAdding: .month, value: monthOffset, to: viewModel.currentMonth) ?? viewModel.currentMonth
        let isCurrent = monthOffset == 0
        let days = daysInMonth(for: month)
        let weeks = CGFloat(Int(ceil(Double(days.count) / 7.0)))
        let spacing = 4 * (weeks - 1)
        let cellH = max(44, (gridHeight - spacing) / weeks)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date {
                    DayCell(
                        date: date,
                        isSelected: isCurrent && Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                        isToday: Calendar.current.isDateInToday(date),
                        events: isCurrent ? viewModel.events(for: date) : [],
                        hasHealthRecord: isCurrent && !viewModel.healthRecords(for: date).isEmpty,
                        hasMedication: isCurrent && !viewModel.medications(for: date).isEmpty,
                        cellHeight: cellH
                    )
                    .onTapGesture {
                        guard isCurrent else { return }
                        viewModel.selectDate(date)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isWeekMode = true
                        }
                    }
                } else {
                    Color.clear.frame(height: cellH)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private func daysInMonth(for month: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }
        let weekdayOffset = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: weekdayOffset)
        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        return days
    }
}

// MARK: - 병원 일정 입력 시트 (CalendarView용)

private struct CalendarHospitalVisitFormSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var visitType = "내원"
    @State private var memo = ""

    private let visitTypes = ["내원", "채혈", "초음파"]

    var body: some View {
        NavigationView {
            Form {
                Section("방문 유형") {
                    Picker("방문 유형", selection: $visitType) {
                        ForEach(visitTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("메모 (선택)") {
                    TextField("예: 담당 의사 면담", text: $memo)
                }
            }
            .navigationTitle("병원 일정 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            let note = memo.trimmingCharacters(in: .whitespacesAndNewlines)
                            let fullNote = note.isEmpty ? visitType : "\(visitType) — \(note)"
                            await viewModel.addEvent(.hospitalVisit(note: fullNote), to: viewModel.selectedDate)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 생리 주기 입력 시트

private struct MenstrualCycleFormSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var startDate: Date
    @State private var cycleLength: Int = 28

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일"
        return f
    }()

    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        _startDate = State(initialValue: viewModel.selectedDate)
    }

    private var ovulationDate: Date {
        Calendar.current.date(byAdding: .day, value: cycleLength / 2, to: startDate) ?? startDate
    }

    var body: some View {
        NavigationView {
            Form {
                Section("생리 시작일") {
                    DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }

                Section("주기 설정") {
                    Stepper("\(cycleLength)일 주기", value: $cycleLength, in: 21 ... 42)
                }

                Section("배란 예정일") {
                    HStack {
                        Text("예상 배란일")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(Self.dateFormatter.string(from: ovulationDate))
                            .fontWeight(.medium)
                            .foregroundStyle(AranColor.dotOvulation)
                    }
                }
            }
            .navigationTitle("생리 주기 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await viewModel.addEvent(.periodStart, to: startDate)
                            await viewModel.addEvent(.ovulation, to: ovulationDate)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - DayCell

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let events: [DayEvent]
    let hasHealthRecord: Bool
    let hasMedication: Bool
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
                if hasMedication {
                    Circle()
                        .fill(AranColor.dotMedication)
                        .frame(width: 5, height: 5)
                }
                if hasHealthRecord {
                    Circle()
                        .fill(AranColor.dotHealthRecord)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(height: cellHeight)
    }
}
