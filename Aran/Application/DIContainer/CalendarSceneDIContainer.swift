//
//  CalendarSceneDIContainer.swift
//  Aran
//

import SwiftData

@MainActor
final class CalendarSceneDIContainer {
    struct Dependencies {
        let modelContext: ModelContext
    }

    private let dependencies: Dependencies

    private lazy var cycleRecordRepository: CycleRecordRepositoryProtocol =
        CycleRecordRepository(context: dependencies.modelContext)

    private lazy var cycleRecordUseCase: CycleRecordUseCase =
        .init(repository: cycleRecordRepository)

    private lazy var healthRecordRepository: HealthRecordRepositoryProtocol =
        HealthRecordRepository(context: dependencies.modelContext)

    private lazy var healthRecordUseCase: HealthRecordUseCase =
        .init(repository: healthRecordRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(
            cycleRecordUseCase: cycleRecordUseCase,
            healthRecordUseCase: healthRecordUseCase
        )
    }
}
