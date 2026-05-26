//
//  ProcedureRecordViewModel.swift
//  Aran
//

import Foundation
import Combine

@MainActor
final class ProcedureRecordViewModel: ObservableObject {
    @Published var transferRecords: [TransferRecord] = []
    @Published var isFormPresented = false
    @Published var errorMessage: String?

    private let transferRecordUseCase: TransferRecordUseCase
    private let cycleRecordUseCase: CycleRecordUseCase

    init(transferRecordUseCase: TransferRecordUseCase, cycleRecordUseCase: CycleRecordUseCase) {
        self.transferRecordUseCase = transferRecordUseCase
        self.cycleRecordUseCase = cycleRecordUseCase
    }

    var sortedCycleNumbers: [Int] {
        Array(Set(transferRecords.map(\.cycleNumber))).sorted()
    }

    func records(for cycleNumber: Int) -> [TransferRecord] {
        transferRecords
            .filter { $0.cycleNumber == cycleNumber }
            .sorted { $0.date < $1.date }
    }

    func load() async {
        do {
            transferRecords = try await transferRecordUseCase.fetchAll()
                .sorted { $0.cycleNumber < $1.cycleNumber }
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
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
