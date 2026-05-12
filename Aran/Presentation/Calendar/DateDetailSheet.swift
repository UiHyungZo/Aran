import SwiftUI

struct DateDetailSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var diaryEmoji = ""
    @State private var diaryText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("날짜") {
                    Text(viewModel.selectedDate, format: .dateTime.year().month().day())
                        .font(AranFont.body())
                }

                Section("이벤트") {
                    let events = viewModel.events(for: viewModel.selectedDate)
                    if events.isEmpty {
                        Text("등록된 이벤트가 없습니다.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(events.indices, id: \.self) { index in
                            EventRow(event: events[index])
                        }
                    }
                }

                Section("감정 일기") {
                    TextField("이모지", text: $diaryEmoji)
                        .font(AranFont.body(24))
                    TextEditor(text: $diaryText)
                        .frame(minHeight: 80)
                        .font(AranFont.body())
                }
            }
            .navigationTitle("날짜 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            await viewModel.saveDiary(
                                emoji: diaryEmoji.isEmpty ? nil : diaryEmoji,
                                text: diaryText
                            )
                            dismiss()
                        }
                    }
                    .disabled(diaryText.isEmpty)
                }
            }
        }
        .onAppear { loadExistingDiary() }
    }

    private func loadExistingDiary() {
        if let diary = viewModel.selectedRecord?.diary {
            diaryEmoji = diary.emoji ?? ""
            diaryText = diary.text
        }
    }
}

private struct EventRow: View {
    let event: DayEvent

    var body: some View {
        HStack {
            Circle()
                .fill(Color(event.dotColor))
                .frame(width: 10, height: 10)
            Text(event.label)
                .font(AranFont.body())
        }
    }
}

private extension DayEvent {
    var label: String {
        switch self {
        case let .hospitalVisit(note): return "병원 방문" + (note.map { " - \($0)" } ?? "")
        case .ovulation: return "배란일"
        case .periodStart: return "생리 시작"
        case let .embryoRetrieval(count): return "난자 채취 \(count)개"
        case let .embryoTransfer(count, type): return "\(type.rawValue) 배아 이식 \(count)개"
        case .medication: return "약물 복용"
        }
    }
}
