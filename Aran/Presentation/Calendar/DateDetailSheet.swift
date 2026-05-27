import SwiftUI

struct DateDetailSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var isDiarySheetPresented = false
    @State private var isHospitalFormPresented = false
    @State private var isTransferFormPresented = false
    @State private var selectedHealthRecord: HealthRecord?
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
        .sheet(isPresented: $isTransferFormPresented) {
            TransferRecordFormView(viewModel: viewModel)
        }
        .sheet(isPresented: $isDiarySheetPresented) {
            DiaryEditSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $isHospitalFormPresented) {
            HospitalVisitFormSheet(viewModel: viewModel)
        }
        .sheet(item: $selectedHealthRecord) { record in
            HealthRecordDetailView(record: record)
        }
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
        Section {
            if !transfers.isEmpty {
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
            } else {
                Text("채취/이식 기록이 없습니다.")
                    .font(AranFont.body())
                    .foregroundStyle(.secondary)
            }
        } header: {
            SectionHeaderView(title: "채취 / 이식", buttonTitle: "추가") {
                isTransferFormPresented = true
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
        Section {
            if events.isEmpty {
                Text("일정이 없습니다.")
                    .font(AranFont.body())
                    .foregroundStyle(.secondary)
            } else {
                ForEach(events.indices, id: \.self) { index in
                    EventRow(event: events[index])
                }
            }
        } header: {
            SectionHeaderView(title: "병원 / 이벤트", buttonTitle: "추가") {
                isHospitalFormPresented = true
            }
        }
    }

    // MARK: - 감정 일기

    private var diarySection: some View {
        Section {
            if let diary = viewModel.selectedRecord?.diary, !diary.text.isEmpty {
                HStack(spacing: 8) {
                    if let emoji = diary.emoji {
                        Text(emoji).font(AranFont.body(22))
                    }
                    Text(diary.text)
                        .font(AranFont.body())
                        .foregroundStyle(.primary)
                        .lineLimit(3)
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
                buttonTitle: viewModel.selectedRecord?.diary != nil ? "편집" : "추가"
            ) {
                isDiarySheetPresented = true
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
                        Text(record.type)
                            .font(AranFont.body())
                        Spacer()
                        Text(String(format: "%.2f %@", record.value, record.unit))
                            .font(AranFont.body())
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedHealthRecord = record }
                }
            } header: {
                SectionHeaderView(title: "검사 수치")
            }
        }
    }

}

// MARK: - 감정 일기 입력 시트

private struct DiaryEditSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var diaryEmoji = ""
    @State private var diaryText = ""

    private let emojiOptions = ["😊", "😟", "😰", "😣", "🥰"]

    var body: some View {
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
                    dismiss()
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
        .presentationDetents([.medium])
        .onAppear {
            if let diary = viewModel.selectedRecord?.diary {
                diaryEmoji = diary.emoji ?? ""
                diaryText = diary.text
            }
        }
    }
}

// MARK: - 병원 일정 입력 시트

private struct HospitalVisitFormSheet: View {
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

// MARK: - 공용 섹션 헤더

private struct SectionHeaderView: View {
    let title: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(AranFont.caption())
                .foregroundStyle(.secondary)
                .textCase(nil)
            if let buttonTitle, let action {
                Spacer()
                Button(buttonTitle, action: action)
                    .font(AranFont.caption())
                    .foregroundStyle(AranColor.primary)
                    .textCase(nil)
            }
        }
    }
}

// MARK: - 채취 / 이식 입력

private struct TransferRecordFormView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var mode: FormMode = .transfer
    @State private var retrievalCount = 1
    @State private var cycleNumber = 1
    @State private var embryoGrade = ""
    @State private var embryoCount = 1
    @State private var transferType: TransferType = .fresh
    @State private var result: TransferResult = .pending

    enum FormMode: String, CaseIterable, Identifiable {
        case retrieval = "채취"
        case transfer = "이식"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationView {
            Form {
                Picker("기록 종류", selection: $mode) {
                    ForEach(FormMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if mode == .retrieval {
                    Stepper("채취 \(retrievalCount)개", value: $retrievalCount, in: 1 ... 50)
                } else {
                    Stepper("\(cycleNumber)차 시술", value: $cycleNumber, in: 1 ... 20)
                    TextField("배아 등급 예: 3AA", text: $embryoGrade)
                    Stepper("이식 \(embryoCount)개", value: $embryoCount, in: 1 ... 10)
                    Picker("이식 유형", selection: $transferType) {
                        Text(TransferType.fresh.rawValue).tag(TransferType.fresh)
                        Text(TransferType.frozen.rawValue).tag(TransferType.frozen)
                    }
                    Picker("결과", selection: $result) {
                        Text(TransferResult.pending.rawValue).tag(TransferResult.pending)
                        Text(TransferResult.success.rawValue).tag(TransferResult.success)
                        Text(TransferResult.failed.rawValue).tag(TransferResult.failed)
                    }
                }
            }
            .navigationTitle("채취 / 이식 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            if mode == .retrieval {
                                await viewModel.saveRetrieval(count: retrievalCount)
                            } else {
                                let grade = embryoGrade.trimmingCharacters(in: .whitespacesAndNewlines)
                                await viewModel.saveTransfer(
                                    cycleNumber: cycleNumber,
                                    embryoGrade: grade.isEmpty ? "미입력" : grade,
                                    embryoCount: embryoCount,
                                    transferType: transferType,
                                    result: result
                                )
                            }
                            dismiss()
                        }
                    }
                }
            }
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

// MARK: - 검사 수치 상세보기

private struct HealthRecordDetailView: View {
    let record: HealthRecord
    @Environment(\.dismiss) private var dismiss

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f
    }()

    var body: some View {
        NavigationView {
            List {
                Section {
                    LabeledContent("검사 항목", value: record.type)
                    LabeledContent("날짜", value: Self.dateFormatter.string(from: record.recordDate))
                }

                Section("수치") {
                    LabeledContent("결과값") {
                        Text(String(format: "%.2f", record.value))
                            .fontWeight(.semibold)
                        + Text(" \(record.unit)")
                            .foregroundColor(.secondary)
                    }
                }

                if let memo = record.memo, !memo.isEmpty {
                    Section("메모") {
                        Text(memo)
                            .font(AranFont.body())
                            .foregroundStyle(.primary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(record.type)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}
