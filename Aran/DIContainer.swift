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

    private lazy var medicationRepository: MedicationRepositoryProtocol =
        MedicationRepository(context: modelContext)

    private lazy var notificationRepository: NotificationRepositoryProtocol =
        NotificationManager()

    private lazy var medicationUseCase: MedicationUseCase =
        MedicationUseCase(
            medicationRepository: medicationRepository,
            notificationRepository: notificationRepository
        )

    private lazy var drugRepository: DrugRepositoryProtocol =
        DrugRepository()

    private lazy var searchDrugUseCase: SearchDrugUseCase =
        SearchDrugUseCase(repository: drugRepository)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(cycleRecordUseCase: cycleRecordUseCase)
    }

    func makeMedicationListViewController() -> MedicationListViewController {
        MedicationListViewController(
            viewModel: MedicationViewModel(medicationUseCase: medicationUseCase),
            medicationUseCase: medicationUseCase,
            searchDrugUseCase: searchDrugUseCase
        )
    }
}
