//
//  ProcedureRecordViewModel.swift
//  Aran
//

import Combine
import Foundation
import AranDomain

struct ProcedureCycleSummary: Identifiable {
    var id: Int { cycleNumber }
    let cycleNumber: Int
    let cycleRecordId: UUID?
    let startDate: Date?
    let retrievalCount: Int
    let fertilizedCount: Int
    let frozenCount: Int
    let embryoRecords: [EmbryoRecord]
    let transferRecords: [TransferRecord]
    let pgtRecords: [PGTRecord]

    var transferredCount: Int {
        transferRecords.reduce(0) { $0 + $1.embryoCount }
    }

    func usedEmbryoCount(type: PGTType, excluding recordId: UUID? = nil) -> Int {
        pgtRecords
            .filter { $0.type == type && $0.id != recordId }
            .reduce(0) { $0 + $1.normalCount + $1.abnormalCount + $1.mosaicCount + $1.inconclusiveCount }
    }

    var displayStartDate: Date {
        startDate
            ?? transferRecords.map(\.date).min()
            ?? pgtRecords.map(\.testDate).min()
            ?? Date()
    }

    var latestResult: TransferResult {
        transferRecords.sorted { $0.date > $1.date }.first?.result ?? .standby
    }
}

struct ProcedureChartEntry: Identifiable {
    let id = UUID()
    let cycleNumber: Int
    let category: String
    let count: Int
}

@MainActor
final class ProcedureRecordViewModel: ObservableObject {
    @Published var cycleRecords: [CycleRecord] = []
    @Published var transferRecords: [TransferRecord] = []
    @Published var pgtRecords: [PGTRecord] = []
    @Published var isLoading = false
    @Published var isFormPresented = false
    @Published var errorMessage: String?

    private let transferRecordUseCase: TransferRecordUseCaseProtocol
    private let cycleRecordUseCase: CycleRecordUseCaseProtocol
    private let pgtRecordUseCase: PGTRecordUseCaseProtocol

    init(
        transferRecordUseCase: TransferRecordUseCaseProtocol,
        cycleRecordUseCase: CycleRecordUseCaseProtocol,
        pgtRecordUseCase: PGTRecordUseCaseProtocol
    ) {
        self.transferRecordUseCase = transferRecordUseCase
        self.cycleRecordUseCase = cycleRecordUseCase
        self.pgtRecordUseCase = pgtRecordUseCase
    }

    var cycleSummaries: [ProcedureCycleSummary] {
        let transferCycleNumbers = Set(transferRecords.map(\.cycleNumber))
        let cycleRecordNumbers = Set(cycleRecords.map(\.cycleNumber))
        let cycleNumbers = transferCycleNumbers
            .union(cycleRecordNumbers)
            .sorted(by: >)

        return cycleNumbers.map { cycleNumber in
            let cycleRecord = cycleRecords.first { $0.cycleNumber == cycleNumber }
            let transfers = records(for: cycleNumber)
            let cyclePGTRecords = cycleRecord.map { self.pgtRecords(for: $0.id) } ?? []

            return ProcedureCycleSummary(
                cycleNumber: cycleNumber,
                cycleRecordId: cycleRecord?.id,
                startDate: cycleRecord?.date,
                retrievalCount: cycleRecord?.retrievalCount ?? 0,
                fertilizedCount: cycleRecord?.fertilizedCount ?? 0,
                frozenCount: cycleRecord?.frozenCount ?? 0,
                embryoRecords: cycleRecord?.embryoRecords ?? [],
                transferRecords: transfers,
                pgtRecords: cyclePGTRecords
            )
        }
    }

    func records(for cycleNumber: Int) -> [TransferRecord] {
        transferRecords
            .filter { $0.cycleNumber == cycleNumber }
            .sorted { $0.date < $1.date }
    }

    func pgtRecords(for cycleRecordId: UUID) -> [PGTRecord] {
        pgtRecords
            .filter { $0.cycleRecordId == cycleRecordId }
            .sorted { $0.testDate < $1.testDate }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let fetchedTransfers = transferRecordUseCase.fetchAll()
            async let fetchedCycles = cycleRecordUseCase.fetchAll()
            async let fetchedPGT = pgtRecordUseCase.fetchAll()

            let transfers = try await fetchedTransfers
            let cycles = try await fetchedCycles
            let pgt = try await fetchedPGT

            transferRecords = transfers.sorted {
                if $0.cycleNumber == $1.cycleNumber {
                    return $0.date < $1.date
                }
                return $0.cycleNumber < $1.cycleNumber
            }
            cycleRecords = cycles.sorted { $0.date < $1.date }
            pgtRecords = pgt.sorted { $0.testDate < $1.testDate }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func saveCycleRecord(
        cycleNumber: Int,
        startDate: Date,
        retrievalCount: Int,
        fertilizedCount: Int,
        frozenCount: Int,
        embryoRecords: [EmbryoRecord]
    ) async -> Bool {
        do {
            try await cycleRecordUseCase.save(
                cycleNumber: cycleNumber,
                startDate: startDate,
                retrievalCount: retrievalCount,
                fertilizedCount: fertilizedCount,
                frozenCount: frozenCount,
                embryoRecords: embryoRecords
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func updateCycleRecord(
        cycleNumber: Int,
        startDate: Date,
        retrievalCount: Int,
        fertilizedCount: Int,
        frozenCount: Int,
        embryoRecords: [EmbryoRecord]
    ) async -> Bool {
        do {
            try await cycleRecordUseCase.update(
                cycleNumber: cycleNumber,
                startDate: startDate,
                retrievalCount: retrievalCount,
                fertilizedCount: fertilizedCount,
                frozenCount: frozenCount,
                embryoRecords: embryoRecords
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func saveMultipleTransfers(
        rows: [(embryoGrade: String, embryoCount: Int, transferType: TransferType, result: TransferResult, memo: String)],
        cycleNumber: Int,
        date: Date
    ) async -> Bool {
        for row in rows {
            let didSave = await saveTransfer(
                cycleNumber: cycleNumber,
                date: date,
                embryoGrade: row.embryoGrade,
                embryoCount: row.embryoCount,
                transferType: row.transferType,
                result: row.result,
                memo: row.memo
            )
            guard didSave else { return false }
        }
        return true
    }

    @discardableResult
    func saveTransfer(
        cycleNumber: Int,
        date: Date,
        embryoGrade: String,
        embryoCount: Int,
        transferType: TransferType,
        result: TransferResult = .waiting,
        memo: String = ""
    ) async -> Bool {
        let trimmedGrade = embryoGrade.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let record = TransferRecord(
            id: UUID(),
            cycleNumber: cycleNumber,
            date: date,
            embryoGrade: trimmedGrade.isEmpty ? "미입력" : trimmedGrade,
            embryoCount: embryoCount,
            transferType: transferType,
            result: result,
            memo: trimmedMemo.isEmpty ? nil : trimmedMemo
        )
        do {
            try await transferRecordUseCase.save(record)
            try await cycleRecordUseCase.addEvent(
                .embryoTransfer(transferID: record.id),
                to: date,
                cycleNumber: cycleNumber
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateTransferResult(id: UUID, result: TransferResult, memo: String?) async {
        do {
            guard var record = try await transferRecordUseCase.fetch(id: id) else { return }
            record.result = result
            record.memo = memo
            try await transferRecordUseCase.update(record)
            await load()
        } catch {
            errorMessage = error.localizedDescription
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
        memo: String = ""
    ) async -> Bool {
        let trimmedGrade = embryoGrade.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            guard var record = try await transferRecordUseCase.fetch(id: id) else {
                errorMessage = "수정할 이식 기록을 찾을 수 없습니다."
                return false
            }

            record.cycleNumber = cycleNumber
            record.date = date
            record.embryoGrade = trimmedGrade.isEmpty ? "미입력" : trimmedGrade
            record.embryoCount = embryoCount
            record.transferType = transferType
            record.result = result
            record.memo = trimmedMemo.isEmpty ? nil : trimmedMemo

            try await transferRecordUseCase.update(record)
            try await cycleRecordUseCase.removeTransferEvent(transferID: id)
            try await cycleRecordUseCase.addEvent(.embryoTransfer(transferID: id), to: date, cycleNumber: cycleNumber)
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func savePGTRecord(
        cycleRecordId: UUID,
        testDate: Date,
        type: PGTType,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        inconclusiveCount: Int = 0,
        resultStatus: PGTResultStatus? = nil,
        femaleChromosomeResult: ChromosomeResult? = nil,
        maleChromosomeResult: ChromosomeResult? = nil,
        implantationTestType: ImplantationTestType? = nil,
        implantationResult: ImplantationResult? = nil,
        recommendedTransferWindow: String? = nil,
        memo: String?
    ) async -> Bool {
        do {
            try await pgtRecordUseCase.save(
                cycleRecordId: cycleRecordId,
                testDate: testDate,
                type: type,
                normalCount: normalCount,
                abnormalCount: abnormalCount,
                mosaicCount: mosaicCount,
                inconclusiveCount: inconclusiveCount,
                resultStatus: type.showsEmbryoCounts ? nil : resultStatus,
                femaleChromosomeResult: femaleChromosomeResult,
                maleChromosomeResult: maleChromosomeResult,
                implantationTestType: implantationTestType,
                implantationResult: implantationResult,
                recommendedTransferWindow: recommendedTransferWindow,
                memo: memo
            )
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func updatePGTRecord(
        id: UUID,
        testDate: Date,
        type: PGTType,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        inconclusiveCount: Int,
        resultStatus: PGTResultStatus?,
        femaleChromosomeResult: ChromosomeResult?,
        maleChromosomeResult: ChromosomeResult?,
        implantationTestType: ImplantationTestType?,
        implantationResult: ImplantationResult?,
        recommendedTransferWindow: String?,
        memo: String?
    ) async -> Bool {
        do {
            guard var record = try await pgtRecordUseCase.fetch(id: id) else {
                errorMessage = "수정할 검사 기록을 찾을 수 없습니다."
                return false
            }
            record.testDate = testDate
            record.type = type
            record.normalCount = normalCount
            record.abnormalCount = abnormalCount
            record.mosaicCount = mosaicCount
            record.inconclusiveCount = inconclusiveCount
            record.resultStatus = type.showsEmbryoCounts ? nil : resultStatus
            record.femaleChromosomeResult = femaleChromosomeResult
            record.maleChromosomeResult = maleChromosomeResult
            record.implantationTestType = implantationTestType
            record.implantationResult = implantationResult
            record.recommendedTransferWindow = recommendedTransferWindow
            record.memo = memo
            try await pgtRecordUseCase.update(record)
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteTransfer(id: UUID) async {
        do {
            try await transferRecordUseCase.delete(id: id)
            try await cycleRecordUseCase.removeTransferEvent(transferID: id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePGT(id: UUID) async {
        do {
            try await pgtRecordUseCase.delete(id: id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCycleRecord(summary: ProcedureCycleSummary) async {
        do {
            for transfer in summary.transferRecords {
                try await transferRecordUseCase.delete(id: transfer.id)
                try await cycleRecordUseCase.removeTransferEvent(transferID: transfer.id)
            }

            for pgt in summary.pgtRecords {
                try await pgtRecordUseCase.delete(id: pgt.id)
            }

            if let id = summary.cycleRecordId {
                try await cycleRecordUseCase.delete(id: id)
            }

            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func chartData() -> [ProcedureChartEntry] {
        cycleSummaries.flatMap { summary in
            [
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "채취", count: summary.retrievalCount),
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "수정", count: summary.fertilizedCount),
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "동결", count: summary.frozenCount),
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "이식", count: summary.transferredCount)
            ]
        }
        .filter { !$0.isEmpty }
    }
}
