import SwiftUI

struct DateDetailSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var diaryEmoji = ""
    @State private var diaryText = ""
    @State private var isEditingDiary = false
    @Environment(\.dismiss) private var dismiss

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f
    }()

    var body: some View {
        NavigationView {
            List {
                dateHeader
                transferSection
                medicationSection
                eventSection
                diarySection
                healthRecordSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Self.dateFormatter.string(from: viewModel.selectedDate))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
        .onAppear { loadExistingDiary() }
    }

    // MARK: - 날짜 헤더

    private var dateHeader: some View {
        Section {
            EmptyView()
        } header: {
            Text(Self.dateFormatter.string(from: viewModel.selectedDate))
                .font(AranFont.body(17))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .textCase(nil)
                .padding(.vertical, 4)
        }
    }

    // MARK: - 채취 / 이식

    @ViewBuilder
    private var transferSection: some View {
        let transfers = viewModel.selectedDateTransferRecords
        if !transfers.isEmpty {
            Section {
                ForEach(transfers) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("\(record.cycleNumber)차 이식")
                                .font(AranFont.body(15))
                                .fontWeight(.semibold)
                            Spacer()
                            Text(record.transferType.rawValue)
                                .font(AranFont.caption())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AranColor.dotTransfer.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        Text("\(record.embryoGrade) \(record.embryoCount)개")
                            .font(AranFont.body())
                            .foregroundStyle(.secondary)
                        Text(record.result.rawValue)
                            .font(AranFont.caption())
                            .foregroundStyle(
                                record.result == .success ? AranColor.dotTransfer
                                    : record.result == .failed ? AranColor.dotPeriod
                                    : .secondary
                            )
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                SectionHeaderView(title: "채취 / 이식", buttonTitle: "편집") {}
            }
        }
    }

    // MARK: - 복용 약

    @ViewBuilder
    private var medicationSection: some View {
        let meds = viewModel.medications(for: viewModel.selectedDate)
        if !meds.isEmpty {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(meds) { med in
                            Text(med.drugName)
                                .font(AranFont.caption())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AranColor.dotMedication.opacity(0.15))
                                .foregroundStyle(AranColor.dotMedication)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                SectionHeaderView(title: "복용 약", buttonTitle: "편집") {}
            }
        }
    }

    // MARK: - 이벤트 (병원/배란/생리/채취)

    @ViewBuilder
    private var eventSection: some View {
        let events = viewModel.events(for: viewModel.selectedDate)
            .filter { event in
                if case .embryoTransfer = event { return false }
                if case .medication = event { return false }
                return true
            }
        if !events.isEmpty {
            Section {
                ForEach(events.indices, id: \.self) { index in
                    EventRow(event: events[index])
                }
            } header: {
                SectionHeaderView(title: "병원 / 이벤트", buttonTitle: "편집") {}
            }
        }
    }

    // MARK: - 감정 일기

    private var diarySection: some View {
        Section {
            if isEditingDiary {
                TextField("이모지", text: $diaryEmoji)
                    .font(AranFont.body(24))
                TextEditor(text: $diaryText)
                    .frame(minHeight: 60)
                    .font(AranFont.body())
                Button("저장") {
                    Task {
                        await viewModel.saveDiary(
                            emoji: diaryEmoji.isEmpty ? nil : diaryEmoji,
                            text: diaryText
                        )
                        isEditingDiary = false
                    }
                }
                .disabled(diaryText.isEmpty)
            } else if let diary = viewModel.selectedRecord?.diary, !diary.text.isEmpty {
                HStack(spacing: 8) {
                    if let emoji = diary.emoji {
                        Text(emoji).font(AranFont.body(22))
                    }
                    Text(diary.text)
                        .font(AranFont.body())
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 2)
            } else {
                Text("기록이 없습니다.")
                    .font(AranFont.body())
                    .foregroundStyle(.secondary)
            }
        } header: {
            SectionHeaderView(
                title: "감정 일기",
                buttonTitle: isEditingDiary ? "취소" : (viewModel.selectedRecord?.diary != nil ? "편집" : "추가")
            ) {
                if isEditingDiary {
                    isEditingDiary = false
                } else {
                    isEditingDiary = true
                }
            }
        }
    }

    // MARK: - 검사 수치

    @ViewBuilder
    private var healthRecordSection: some View {
        let records = viewModel.healthRecords(for: viewModel.selectedDate)
        if !records.isEmpty {
            Section {
                ForEach(records) { record in
                    HStack {
                        Circle()
                            .fill(AranColor.dotHealthRecord)
                            .frame(width: 8, height: 8)
                        Text(record.testItem.rawValue)
                            .font(AranFont.body())
                        Spacer()
                        if record.testItem.isNumeric {
                            Text(String(format: "%.2f %@", record.value, record.testItem.unit))
                                .font(AranFont.body())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                SectionHeaderView(title: "검사 수치", buttonTitle: "추가") {}
            }
        }
    }

    // MARK: -

    private func loadExistingDiary() {
        if let diary = viewModel.selectedRecord?.diary {
            diaryEmoji = diary.emoji ?? ""
            diaryText = diary.text
        }
    }
}

// MARK: - 공용 섹션 헤더

private struct SectionHeaderView: View {
    let title: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(AranFont.caption())
                .foregroundStyle(.secondary)
                .textCase(nil)
            Spacer()
            Button(buttonTitle, action: action)
                .font(AranFont.caption())
                .foregroundStyle(AranColor.primary)
                .textCase(nil)
        }
    }
}

// MARK: - EventRow

private struct EventRow: View {
    let event: DayEvent

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(event.dotColor))
                .frame(width: 8, height: 8)
            Text(event.title)
                .font(AranFont.body())
        }
    }
}

private extension DayEvent {
    var title: String {
        switch self {
        case let .hospitalVisit(note): return "병원 방문" + (note.map { " — \($0)" } ?? "")
        case .ovulation: return "배란일"
        case .periodStart: return "생리 시작"
        case let .embryoRetrieval(count): return "난자 채취 \(count)개"
        case .embryoTransfer: return "배아 이식"
        case .medication: return "약물 복용"
        }
    }
}
