@testable import Aran
import Foundation

final class MockMedicationLogRepository: MedicationLogRepositoryProtocol {
    var logs: [MedicationLog] = []

    func fetchAll() async throws -> [MedicationLog] {
        logs
    }

    func fetch(date: Date) async throws -> [MedicationLog] {
        let day = Calendar.current.startOfDay(for: date)
        return logs.filter { Calendar.current.isDate($0.logDate, inSameDayAs: day) }
    }

    func fetch(medicationId: UUID, date: Date) async throws -> MedicationLog? {
        let day = Calendar.current.startOfDay(for: date)
        return logs.first {
            $0.medicationId == medicationId && Calendar.current.isDate($0.logDate, inSameDayAs: day)
        }
    }

    func fetch(medicationId: UUID, date: Date, timeIndex: Int) async throws -> MedicationLog? {
        let day = Calendar.current.startOfDay(for: date)
        return logs.first {
            $0.medicationId == medicationId
                && Calendar.current.isDate($0.logDate, inSameDayAs: day)
                && $0.timeIndex == timeIndex
        }
    }

    func upsert(_ log: MedicationLog) async throws {
        let day = Calendar.current.startOfDay(for: log.logDate)
        if let index = logs.firstIndex(where: {
            $0.medicationId == log.medicationId
                && Calendar.current.isDate($0.logDate, inSameDayAs: day)
                && $0.timeIndex == log.timeIndex
        }) {
            logs[index] = log
        } else {
            logs.append(log)
        }
    }

    func delete(id: UUID) async throws {
        logs.removeAll { $0.id == id }
    }

    func deleteLogs(for medicationId: UUID) async throws {
        logs.removeAll { $0.medicationId == medicationId }
    }
}
