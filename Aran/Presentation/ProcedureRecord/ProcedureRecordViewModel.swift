//
//  ProcedureRecordViewModel.swift
//  Aran
//

import Combine
import Foundation

struct ProcedureCycleSummary: Identifiable {
    var id: Int { cycleNumber }
    let cycleNumber: Int
    let cycleRecordId: UUID?
    let startDate: Date?
    let retrievalCount: Int
    let fertilizedCount: Int
    let frozenCount: Int
    let embryoGrades: [String]
    let transferRecords: [TransferRecord]
    let pgtRecords: [PGTRecord]

    var transferredCount: Int {
        transferRecords.reduce(0) { $0 + $1.embryoCount }
    }

    var displayStartDate: Date {
        startDate
            ?? transferRecords.map(\.date).min()
            ?? pgtRecords.map(\.testDate).min()
            ?? Date()
    }

    var latestResult: TransferResult {
        transferRecords.sorted { $0.date > $1.date }.first?.result ?? .pending
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
                embryoGrades: cycleRecord?.embryoGrades ?? [],
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

    func saveCycleRecord(
        cycleNumber: Int,
        startDate: Date,
        retrievalCount: Int,
        fertilizedCount: Int,
        frozenCount: Int,
        embryoGrades: [String]
    ) async {
        do {
            try await cycleRecordUseCase.save(
                cycleNumber: cycleNumber,
                startDate: startDate,
                retrievalCount: retrievalCount,
                fertilizedCount: fertilizedCount,
                frozenCount: frozenCount,
                embryoGrades: embryoGrades
            )
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveTransfer(
        cycleNumber: Int,
        date: Date,
        embryoGrade: String,
        embryoCount: Int,
        transferType: TransferType,
        result: TransferResult = .pending
    ) async {
        let record = TransferRecord(
            id: UUID(),
            cycleNumber: cycleNumber,
            date: date,
            embryoGrade: embryoGrade,
            embryoCount: embryoCount,
            transferType: transferType,
            result: result,
            memo: nil
        )
        do {
            try await transferRecordUseCase.save(record)
            try await cycleRecordUseCase.addEvent(
                .embryoTransfer(transferID: record.id),
                to: date,
                cycleNumber: cycleNumber
            )
            await load()
        } catch {
            errorMessage = error.localizedDescription
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

    func savePGTRecord(
        cycleRecordId: UUID,
        testDate: Date,
        type: PGTType,
        normalCount: Int,
        abnormalCount: Int,
        mosaicCount: Int,
        memo: String?
    ) async {
        do {
            try await pgtRecordUseCase.save(
                cycleRecordId: cycleRecordId,
                testDate: testDate,
                type: type,
                normalCount: normalCount,
                abnormalCount: abnormalCount,
                mosaicCount: mosaicCount,
                memo: memo
            )
            await load()
        } catch {
            errorMessage = error.localizedDescription
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

    func chartData() -> [ProcedureChartEntry] {
        cycleSummaries.flatMap { summary in
            [
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "채취", count: summary.retrievalCount),
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "수정", count: summary.fertilizedCount),
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "동결", count: summary.frozenCount),
                ProcedureChartEntry(cycleNumber: summary.cycleNumber, category: "이식", count: summary.transferredCount)
            ]
        }
        .filter { $0.count > 0 }
    }
}
