import Combine
import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = .init()
    @Published var currentMonth: Date = .init()
    @Published var cycleRecords: [Date: CycleRecord] = [:]
    @Published var healthRecords: [Date: [HealthRecord]] = [:]
    @Published var selectedRecord: CycleRecord?
    @Published var selectedDateTransferRecords: [TransferRecord] = []
    @Published var isDetailSheetPresented = false
    @Published var errorMessage: String?

    @Published var allMedications: [Medication] = []

    private let cycleRecordUseCase: CycleRecordUseCase
    private let healthRecordUseCase: HealthRecordUseCase
    private let transferRecordUseCase: TransferRecordUseCase
    private let medicationUseCase: MedicationUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        cycleRecordUseCase: CycleRecordUseCase,
        healthRecordUseCase: HealthRecordUseCase,
        transferRecordUseCase: TransferRecordUseCase,
        medicationUseCase: MedicationUseCase
    ) {
        self.cycleRecordUseCase = cycleRecordUseCase
        self.healthRecordUseCase = healthRecordUseCase
        self.transferRecordUseCase = transferRecordUseCase
        self.medicationUseCase = medicationUseCase
        bindSelectedDate()
    }

    private func bindSelectedDate() {
        $selectedDate
            .removeDuplicates()
            .sink { [weak self] date in
                Task { @MainActor [weak self] in
                    await self?.loadRecord(for: date)
                }
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

            allMedications = try await medicationUseCase.fetchAll()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func medications(for date: Date) -> [Medication] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        return allMedications.filter { med in
            let start = calendar.startOfDay(for: med.schedule.startDate)
            guard start <= day else { return false }
            if let end = med.schedule.endDate {
                return day <= calendar.startOfDay(for: end)
            }
            return true
        }
    }

    func healthRecords(for date: Date) -> [HealthRecord] {
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
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveRetrieval(count: Int) async {
        do {
            try await cycleRecordUseCase.addEvent(.embryoRetrieval(count: count), to: selectedDate)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveTransfer(
        cycleNumber: Int,
        embryoGrade: String,
        embryoCount: Int,
        transferType: TransferType,
        result: TransferResult
    ) async {
        do {
            let record = TransferRecord(
                id: UUID(),
                cycleNumber: cycleNumber,
                date: selectedDate,
                embryoGrade: embryoGrade,
                embryoCount: embryoCount,
                transferType: transferType,
                result: result
            )
            try await transferRecordUseCase.save(record)
            try await cycleRecordUseCase.addEvent(.embryoTransfer(transferID: record.id), to: selectedDate)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func loadRecord(for date: Date) async {
        let key = Calendar.current.startOfDay(for: date)
        selectedRecord = cycleRecords[key]
        selectedDateTransferRecords = (try? await transferRecordUseCase.fetch(for: date)) ?? []
    }

    func events(for date: Date) -> [DayEvent] {
        let key = Calendar.current.startOfDay(for: date)
        return cycleRecords[key]?.events ?? []
    }
}
