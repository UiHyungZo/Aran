import Combine
import Foundation
import AranDomain

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

    private let cycleRecordUseCase: CycleRecordUseCaseProtocol
    private let healthRecordUseCase: HealthRecordUseCaseProtocol
    private let transferRecordUseCase: TransferRecordUseCaseProtocol
    private let medicationUseCase: MedicationUseCaseProtocol
    private let hospitalVisitUseCase: HospitalVisitUseCaseProtocol
    private let menstrualCycleUseCase: MenstrualCycleUseCaseProtocol
    private let medicationLogUseCase: MedicationLogUseCaseProtocol
    private let diaryEntryUseCase: DiaryEntryUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        cycleRecordUseCase: CycleRecordUseCaseProtocol,
        healthRecordUseCase: HealthRecordUseCaseProtocol,
        transferRecordUseCase: TransferRecordUseCaseProtocol,
        medicationUseCase: MedicationUseCaseProtocol,
        hospitalVisitUseCase: HospitalVisitUseCaseProtocol,
        menstrualCycleUseCase: MenstrualCycleUseCaseProtocol,
        medicationLogUseCase: MedicationLogUseCaseProtocol,
        diaryEntryUseCase: DiaryEntryUseCaseProtocol
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
            cycleRecords = records.reduce(into: [Date: CycleRecord]()) { result, record in
                let key = Calendar.current.startOfDay(for: record.date)
                guard var existing = result[key] else {
                    result[key] = record
                    return
                }
                existing.retrievalCount = max(existing.retrievalCount, record.retrievalCount)
                existing.fertilizedCount = max(existing.fertilizedCount, record.fertilizedCount)
                existing.frozenCount = max(existing.frozenCount, record.frozenCount)
                existing.embryoRecords.append(contentsOf: record.embryoRecords)
                existing.events.append(contentsOf: record.events)
                existing.diary = existing.diary ?? record.diary
                result[key] = existing
            }

            let health = try await healthRecordUseCase.fetchAll()
            var grouped: [Date: [HealthRecord]] = [:]
            for h in health {
                let key = Calendar.current.startOfDay(for: h.recordDate)
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

    func isMedicationTaken(_ medication: Medication, on date: Date, timeSlotID: UUID) -> Bool {
        let key = Calendar.current.startOfDay(for: date)
        return medicationLogs[key]?.first {
            $0.medicationId == medication.id && $0.timeSlotID == timeSlotID
        }?.isTaken ?? false
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
            guard let end = Calendar.current.date(byAdding: .day, value: cycle.periodLength, to: start) else {
                return false
            }
            return day >= start && day < end
        }
    }

    func isPredictedPeriodDate(_ date: Date) -> Bool {
        guard !isPeriodDate(date) else { return false }
        guard let latest = latestCycle else { return false }
        let day = Calendar.current.startOfDay(for: date)
        let nextStart = Calendar.current.startOfDay(for: menstrualCycleUseCase.nextPeriodDate(after: latest))
        guard let end = Calendar.current.date(byAdding: .day, value: latest.periodLength, to: nextStart) else {
            return false
        }
        return day >= nextStart && day < end
    }

    private var latestCycle: MenstrualCycle? {
        menstrualCycles.max { $0.startDate < $1.startDate }
    }

    var nextPredictedPeriodDate: Date? {
        guard let latest = latestCycle else { return nil }
        return menstrualCycleUseCase.nextPeriodDate(after: latest)
    }

    var nextOvulationDate: Date? {
        guard let latest = latestCycle else { return nil }
        return menstrualCycleUseCase.calculateOvulationDate(startDate: latest.startDate, cycleLength: latest.cycleLength)
    }

    var daysUntilNextPeriod: Int? {
        guard let next = nextPredictedPeriodDate else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: next)
        return Calendar.current.dateComponents([.day], from: today, to: target).day
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

    func deleteDiary() async {
        let key = Calendar.current.startOfDay(for: selectedDate)
        do {
            if let entry = diaryEntries[key] {
                try await diaryEntryUseCase.delete(id: entry.id)
            }
            try await cycleRecordUseCase.clearDiary(for: selectedDate)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
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

    func saveMenstrualCycle(startDate: Date, cycleLength: Int, periodLength: Int) async {
        do {
            try await menstrualCycleUseCase.save(startDate: startDate, cycleLength: cycleLength, periodLength: periodLength)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func deleteMenstrualCycle(id: UUID) async {
        do {
            try await menstrualCycleUseCase.delete(id: id)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func ovulationDate(startDate: Date, cycleLength: Int) -> Date {
        menstrualCycleUseCase.calculateOvulationDate(startDate: startDate, cycleLength: cycleLength)
    }

    func toggleMedicationLog(medicationId: UUID, date: Date, timeSlotID: UUID) async {
        do {
            try await medicationLogUseCase.toggle(medicationId: medicationId, date: date, timeSlotID: timeSlotID)
            let key = Calendar.current.startOfDay(for: date)
            medicationLogs[key] = try await medicationLogUseCase.fetch(date: date)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveHealthRecord(type: String, value: Double, unit: String, date: Date, memo: String?) async {
        do {
            try await healthRecordUseCase.save(type: type, value: value, unit: unit, recordDate: date, memo: memo)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func updateHealthRecord(_ record: HealthRecord) async {
        do {
            try await healthRecordUseCase.update(record)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    func deleteHealthRecord(id: UUID) async {
        do {
            try await healthRecordUseCase.delete(id: id)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    @discardableResult
    func saveRetrieval(count: Int) async -> Bool {
        do {
            try await cycleRecordUseCase.addEvent(.embryoRetrieval(count: count), to: selectedDate)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
            return true
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }

    @discardableResult
    func saveTransfer(
        cycleNumber: Int,
        date: Date? = nil,
        embryoGrade: String,
        embryoCount: Int,
        transferType: TransferType,
        result: TransferResult,
        memo: String? = nil
    ) async -> Bool {
        do {
            let transferDate = date ?? selectedDate
            let record = TransferRecord(
                id: UUID(),
                cycleNumber: cycleNumber,
                date: transferDate,
                embryoGrade: embryoGrade,
                embryoCount: embryoCount,
                transferType: transferType,
                result: result,
                memo: memo
            )
            try await transferRecordUseCase.save(record)
            try await cycleRecordUseCase.addEvent(
                .embryoTransfer(transferID: record.id),
                to: transferDate,
                cycleNumber: cycleNumber
            )
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
            return true
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }

    @discardableResult
    func updateTransfer(
        id: UUID,
        cycleNumber: Int,
        date: Date,
        embryoGrade: String,
        embryoCount: Int,
        transferType: TransferType,
        result: TransferResult,
        memo: String?
    ) async -> Bool {
        do {
            guard var record = try await transferRecordUseCase.fetch(id: id) else {
                errorMessage = "수정할 이식 기록을 찾을 수 없습니다."
                return false
            }

            record.cycleNumber = cycleNumber
            record.date = date
            record.embryoGrade = embryoGrade
            record.embryoCount = embryoCount
            record.transferType = transferType
            record.result = result
            record.memo = memo

            try await transferRecordUseCase.update(record)
            try await cycleRecordUseCase.removeTransferEvent(transferID: id)
            try await cycleRecordUseCase.addEvent(.embryoTransfer(transferID: id), to: date, cycleNumber: cycleNumber)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
            return true
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }

    @discardableResult
    func deleteTransfer(id: UUID) async -> Bool {
        do {
            try await transferRecordUseCase.delete(id: id)
            try await cycleRecordUseCase.removeTransferEvent(transferID: id)
            await loadMonthRecords()
            await loadRecord(for: selectedDate)
            return true
        } catch {
            errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
            return false
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
        if isPredictedPeriodDate(date) {
            events.append(.periodPredicted)
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
