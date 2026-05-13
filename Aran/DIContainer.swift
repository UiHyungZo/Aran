//
//  DIContainer.swift
//  Aran
//

import SwiftData

@MainActor
final class DIContainer {
    private let modelContext: ModelContext

    private lazy var cycleRecordRepository: CycleRecordRepositoryProtocol =
        CycleRecordRepository(context: modelContext)

    private lazy var cycleRecordUseCase: CycleRecordUseCase =
        CycleRecordUseCase(repository: cycleRecordRepository)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(cycleRecordUseCase: cycleRecordUseCase)
    }
}
