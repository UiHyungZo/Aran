import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var cycleRecords: [Date: CycleRecord] = [:]
    @Published var selectedRecord: CycleRecord?
    @Published var isDetailSheetPresented = false
    @Published var errorMessage: String?

    private let cycleRecordUseCase: CycleRecordUseCase
    private var cancellables = Set<AnyCancellable>()

    init(cycleRecordUseCase: CycleRecordUseCase) {
        self.cycleRecordUseCase = cycleRecordUseCase
        bindSelectedDate()
    }

    private func bindSelectedDate() {
        $selectedDate
            .removeDuplicates()
            .sink { [weak self] date in
                Task { await self?.loadRecord(for: date) }
            }
            .store(in: &cancellables)
    }

    func loadMonthRecords() async {
        do {
            let records = try await cycleRecordUseCase.fetchAll()
            cycleRecords = Dictionary(
                uniqueKeysWithValues: records.map { (Calendar.current.startOfDay(for: $0.date), $0) }
            )
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        isDetailSheetPresented = true
    }

    func navigateMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = newMonth
        Task { await loadMonthRecords() }
    }

    func addEvent(_ event: DayEvent, to date: Date) async {
        do {
            try await cycleRecordUseCase.addEvent(event, to: date)
            await loadMonthRecords()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveDiary(emoji: String?, text: String) async {
        do {
            try await cycleRecordUseCase.saveDiary(emoji: emoji, text: text, for: selectedDate)
            await loadMonthRecords()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func loadRecord(for date: Date) async {
        let key = Calendar.current.startOfDay(for: date)
        selectedRecord = cycleRecords[key]
    }

    func events(for date: Date) -> [DayEvent] {
        let key = Calendar.current.startOfDay(for: date)
        return cycleRecords[key]?.events ?? []
    }
}
