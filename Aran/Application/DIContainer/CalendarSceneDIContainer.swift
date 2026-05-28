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

    private lazy var cycleRecordUseCase: CycleRecordUseCaseProtocol =
        CycleRecordUseCase(repository: cycleRecordRepository)

    private lazy var healthRecordRepository: HealthRecordRepositoryProtocol =
        HealthRecordRepository(context: dependencies.modelContext)

    private lazy var healthRecordUseCase: HealthRecordUseCaseProtocol =
        HealthRecordUseCase(repository: healthRecordRepository)

    private lazy var transferRecordRepository: TransferRecordRepositoryProtocol =
        TransferRecordRepository(context: dependencies.modelContext)

    private lazy var transferRecordUseCase: TransferRecordUseCaseProtocol =
        TransferRecordUseCase(repository: transferRecordRepository)

    private lazy var medicationRepository: MedicationRepositoryProtocol =
        MedicationRepository(context: dependencies.modelContext)

    private lazy var notificationRepository: NotificationRepositoryProtocol =
        NotificationManager()

    private lazy var medicationUseCase: MedicationUseCaseProtocol =
        MedicationUseCase(medicationRepository: medicationRepository, notificationRepository: notificationRepository)

    private lazy var hospitalVisitRepository: HospitalVisitRepositoryProtocol =
        HospitalVisitRepository(context: dependencies.modelContext)

    private lazy var hospitalVisitUseCase: HospitalVisitUseCaseProtocol =
        HospitalVisitUseCase(repository: hospitalVisitRepository)

    private lazy var menstrualCycleRepository: MenstrualCycleRepositoryProtocol =
        MenstrualCycleRepository(context: dependencies.modelContext)

    private lazy var menstrualCycleUseCase: MenstrualCycleUseCaseProtocol =
        MenstrualCycleUseCase(repository: menstrualCycleRepository)

    private lazy var medicationLogRepository: MedicationLogRepositoryProtocol =
        MedicationLogRepository(context: dependencies.modelContext)

    private lazy var medicationLogUseCase: MedicationLogUseCaseProtocol =
        MedicationLogUseCase(repository: medicationLogRepository)

    private lazy var diaryEntryRepository: DiaryEntryRepositoryProtocol =
        DiaryEntryRepository(context: dependencies.modelContext)

    private lazy var diaryEntryUseCase: DiaryEntryUseCaseProtocol =
        DiaryEntryUseCase(repository: diaryEntryRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(
            cycleRecordUseCase: cycleRecordUseCase,
            healthRecordUseCase: healthRecordUseCase,
            transferRecordUseCase: transferRecordUseCase,
            medicationUseCase: medicationUseCase,
            hospitalVisitUseCase: hospitalVisitUseCase,
            menstrualCycleUseCase: menstrualCycleUseCase,
            medicationLogUseCase: medicationLogUseCase,
            diaryEntryUseCase: diaryEntryUseCase
        )
    }
}
