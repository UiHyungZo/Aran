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
    @Published var errorMessage: String?

    @Published var allMedications: [Medication] = []
    @Published var hospitalVisits: [Date: [HospitalVisit]] = [:]
    @Published var menstrualCycles: [MenstrualCycle] = []
    @Published var medicationLogs: [Date: [MedicationLog]] = [:]
    @Published var diaryEntries: [Date: DiaryEntry] = [:]
    @Published var selectedDiary: DiaryEntry?

    private let cycleRecordUseCase: CycleRecordUseCase
    private let healthRecordUseCase: HealthRecordUseCase
    private let transferRecordUseCase: TransferRecordUseCase
    private let medicationUseCase: MedicationUseCase
    private let hospitalVisitUseCase: HospitalVisitUseCase
    private let menstrualCycleUseCase: MenstrualCycleUseCase
    private let medicationLogUseCase: MedicationLogUseCase
    private let diaryEntryUseCase: DiaryEntryUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        cycleRecordUseCase: CycleRecordUseCase,
        healthRecordUseCase: HealthRecordUseCase,
        transferRecordUseCase: TransferRecordUseCase,
        medicationUseCase: MedicationUseCase,
        hospitalVisitUseCase: HospitalVisitUseCase,
        menstrualCycleUseCase: MenstrualCycleUseCase,
        medicationLogUseCase: MedicationLogUseCase,
        diaryEntryUseCase: DiaryEntryUseCase
    ) {
        self.cycleRecordUseCase = cycleRecordUseCase
        self.healthRecordUseCase = healthRecordUseCase
        self.transferRecordUseCase = transferRecordUseCase
        self.medicationUseCase = medicationUseCase
        self.hospitalVisitUseCase = hospitalVisitUseCase
        self.menstrualCycleUseCase = menstrualCycleUseCase
        self.medicationLogUseCase = medicationLogUseCase
        self.diaryEntryUseCase = diaryEntryUseCase
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

            let visits = try await hospitalVisitUseCase.fetchAll()
            hospitalVisits = Dictionary(grouping: visits) {
                Calendar.current.startOfDay(for: $0.visitDate)
            }

            menstrualCycles = try await menstrualCycleUseCase.fetchAll()

            let logs = try await medicationLogUseCase.fetchAll()
            medicationLogs = Dictionary(grouping: logs) {
                Calendar.current.startOfDay(for: $0.logDate)
            }

            let diaries = try await diaryEntryUseCase.fetchAll()
            var diaryMap: [Date: DiaryEntry] = [:]
            for diary in diaries {
                diaryMap[Calendar.current.startOfDay(for: diary.date)] = diary
            }
            diaryEntries = diaryMap
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

    func hospitalVisits(for date: Date) -> [HospitalVisit] {
        hospitalVisits[Calendar.current.startOfDay(for: date)] ?? []
    }

    func medicationLog(for medicationId: UUID, date: Date) -> MedicationLog? {
        let key = Calendar.current.startOfDay(for: date)
        return medicationLogs[key]?.first { $0.medicationId == medicationId }
    }

    func isMedicationTaken(_ medication: Medication, on date: Date) -> Bool {
        medicationLog(for: medication.id, date: date)?.isTaken ?? false
    }

    func diary(for date: Date) -> DiaryEntry? {
        let key = Calendar.current.startOfDay(for: date)
        return diaryEntries[key] ?? cycleRecords[key]?.diary
    }

    func menstrualCycleStarting(on date: Date) -> MenstrualCycle? {
        let key = Calendar.current.startOfDay(for: date)
        return menstrualCycles.first { Calendar.current.isDate($0.startDate, inSameDayAs: key) }
    }

    func isPeriodDate(_ date: Date) -> Bool {
        let day = Calendar.current.startOfDay(for: date)
        return menstrualCycles.contains { cycle in
            let start = Calendar.current.startOfDay(for: cycle.startDate)
            guard let end = Calendar.current.date(byAdding: .day, value: cycle.cycleLength, to: start) else {
                return false
            }
            return day >= start && day < end
        }
    }

    func isOvulationDate(_ date: Date) -> Bool {
        menstrualCycles.contains { cycle in
            let ovulation = menstrualCycleUseCase.calculateOvulationDate(
                startDate: cycle.startDate,
                cycleLength: cycle.cycleLength
            )
            return Calendar.current.isDate(date, inSameDayAs: ovulation)
        }
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
            try await diaryEntryUseCase.save(date: selectedDate, emoji: emoji, content: text)
            try await cycleRecordUseCase.saveDiary(emoji: emoji, text: text, for: selectedDate)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveHospitalVisit(visitTypes: [String], memo: String?) async {
        do {
            try await hospitalVisitUseCase.save(visitDate: selectedDate, visitTypes: visitTypes, memo: memo)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func updateHospitalVisit(_ visit: HospitalVisit) async {
        do {
            try await hospitalVisitUseCase.update(visit)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func deleteHospitalVisit(id: UUID) async {
        do {
            try await hospitalVisitUseCase.delete(id: id)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveMenstrualCycle(startDate: Date, cycleLength: Int) async {
        do {
            try await menstrualCycleUseCase.save(startDate: startDate, cycleLength: cycleLength)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func ovulationDate(startDate: Date, cycleLength: Int) -> Date {
        menstrualCycleUseCase.calculateOvulationDate(startDate: startDate, cycleLength: cycleLength)
    }

    func toggleMedicationLog(medicationId: UUID, date: Date) async {
        do {
            try await medicationLogUseCase.toggle(medicationId: medicationId, date: date)
            await loadMonthRecords()
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveHealthRecord(item: TestItem, value: Double, date: Date, note: String?) async {
        do {
            try await healthRecordUseCase.save(item: item, value: value, date: date, note: note)
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
        selectedDiary = diaryEntries[key] ?? cycleRecords[key]?.diary
        selectedDateTransferRecords = (try? await transferRecordUseCase.fetch(for: date)) ?? []
    }

    func events(for date: Date) -> [DayEvent] {
        let key = Calendar.current.startOfDay(for: date)
        var events = cycleRecords[key]?.events ?? []
        events.append(contentsOf: hospitalVisits(for: date).map { visit in
            .hospitalVisit(note: visitSummary(visit))
        })
        if isPeriodDate(date) {
            events.append(.periodStart)
        }
        if isOvulationDate(date) {
            events.append(.ovulation)
        }
        return events
    }

    private func visitSummary(_ visit: HospitalVisit) -> String {
        let typeText = visit.visitTypes.joined(separator: ", ")
        guard let memo = visit.memo?.trimmingCharacters(in: .whitespacesAndNewlines), !memo.isEmpty else {
            return typeText
        }
        return "\(typeText) - \(memo)"
    }
}
