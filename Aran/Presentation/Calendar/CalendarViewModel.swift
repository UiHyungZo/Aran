import Combine
import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = .init()
    @Published var currentMonth: Date = .init()
    @Published var cycleRecords: [Date: CycleRecord] = [:]
    @Published var healthRecords: [Date: [HealthRecord]] = [:]
    @Published var selectedRecord: CycleRecord?
    @Published var isDetailSheetPresented = false
    @Published var errorMessage: String?

    private let cycleRecordUseCase: CycleRecordUseCase
    private let healthRecordUseCase: HealthRecordUseCase
    private var cancellables = Set<AnyCancellable>()

    init(cycleRecordUseCase: CycleRecordUseCase, healthRecordUseCase: HealthRecordUseCase) {
        self.cycleRecordUseCase = cycleRecordUseCase
        self.healthRecordUseCase = healthRecordUseCase
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

            let health = try await healthRecordUseCase.fetchAll()
            var grouped: [Date: [HealthRecord]] = [:]
            for h in health {
                let key = Calendar.current.startOfDay(for: h.date)
                grouped[key, default: []].append(h)
            }
            healthRecords = grouped
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func healthRecordsForDate(_ date: Date) -> [HealthRecord] {
        healthRecords[Calendar.current.startOfDay(for: date)] ?? []
    }

    func selectDate(_ date: Date) {
        selectedDate = date
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
