//
//  ProcedureRecordViewModel.swift
//  Aran
//

import Foundation
import Combine

@MainActor
final class ProcedureRecordViewModel: ObservableObject {
    @Published var transferRecords: [TransferRecord] = []
    @Published private(set) var cycleRecords: [CycleRecord] = []
    @Published var isFormPresented = false
    @Published var errorMessage: String?

    private let transferRecordUseCase: TransferRecordUseCase
    private let cycleRecordUseCase: CycleRecordUseCase

    init(transferRecordUseCase: TransferRecordUseCase, cycleRecordUseCase: CycleRecordUseCase) {
        self.transferRecordUseCase = transferRecordUseCase
        self.cycleRecordUseCase = cycleRecordUseCase
    }

    var sortedCycleNumbers: [Int] {
        Array(Set(procedureSummaries.map(\.cycleNumber))).sorted()
    }

    var procedureSummaries: [ProcedureCycleSummary] {
        let retrievalSummaries = retrievalEventsByCycleNumber()
        let transferSummaries = Dictionary(grouping: transferRecords, by: \.cycleNumber)

        let cycleNumbers = Set(retrievalSummaries.keys).union(transferSummaries.keys)

        return cycleNumbers
            .map { cycleNumber in
                let retrieval = retrievalSummaries[cycleNumber]
                let transfers = transferSummaries[cycleNumber, default: []]
                    .sorted { $0.date < $1.date }
                return ProcedureCycleSummary(
                    cycleNumber: cycleNumber,
                    retrievalDate: retrieval?.date,
                    retrievedCount: retrieval?.count,
                    transferRecords: transfers
                )
            }
            .sorted { $0.cycleNumber < $1.cycleNumber }
    }

    func records(for cycleNumber: Int) -> [TransferRecord] {
        transferRecords
            .filter { $0.cycleNumber == cycleNumber }
            .sorted { $0.date < $1.date }
    }

    func load() async {
        do {
            transferRecords = try await transferRecordUseCase.fetchAll()
                .sorted { $0.date < $1.date }
            cycleRecords = try await cycleRecordUseCase.fetchAll()
                .sorted { $0.date < $1.date }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func summary(for cycleNumber: Int) -> ProcedureCycleSummary? {
        procedureSummaries.first { $0.cycleNumber == cycleNumber }
    }

    func saveRetrieval(date: Date, retrievedCount: Int) async {
        do {
            try await cycleRecordUseCase.addEvent(.embryoRetrieval(count: retrievedCount), to: date)
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
        result: TransferResult
    ) async {
        let record = TransferRecord(
            id: UUID(),
            cycleNumber: cycleNumber,
            date: date,
            embryoGrade: embryoGrade,
            embryoCount: embryoCount,
            transferType: transferType,
            result: result
        )
        do {
            try await transferRecordUseCase.save(record)
            try await cycleRecordUseCase.addEvent(.embryoTransfer(transferID: record.id), to: date)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(id: UUID) async {
        do {
            try await transferRecordUseCase.delete(id: id)
            try await cycleRecordUseCase.removeTransferEvent(transferID: id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func retrievalEventsByCycleNumber() -> [Int: ProcedureRetrievalSummary] {
        let retrievals = cycleRecords
            .flatMap { record in
                record.events.compactMap { event -> ProcedureRetrievalSummary? in
                    guard case let .embryoRetrieval(count) = event else { return nil }
                    return ProcedureRetrievalSummary(date: record.date, count: count)
                }
            }
            .sorted { $0.date < $1.date }

        return Dictionary(uniqueKeysWithValues: retrievals.enumerated().map { index, retrieval in
            (index + 1, retrieval)
        })
    }
}

struct ProcedureRetrievalSummary {
    let date: Date
    let count: Int
}

struct ProcedureCycleSummary: Identifiable {
    let cycleNumber: Int
    let retrievalDate: Date?
    let retrievedCount: Int?
    let transferRecords: [TransferRecord]

    var id: Int { cycleNumber }

    var transferredCount: Int {
        transferRecords.reduce(0) { $0 + $1.embryoCount }
    }

    var latestTransferResult: TransferResult? {
        transferRecords.sorted { $0.date < $1.date }.last?.result
    }
}
