//
//  ProcedureRecordSceneDIContainer.swift
//  Aran
//

import SwiftData

@MainActor
final class ProcedureRecordSceneDIContainer {
    struct Dependencies {
        let modelContext: ModelContext
    }

    private let dependencies: Dependencies

    private lazy var transferRecordRepository: TransferRecordRepositoryProtocol =
        TransferRecordRepository(context: dependencies.modelContext)

    private lazy var cycleRecordRepository: CycleRecordRepositoryProtocol =
        CycleRecordRepository(context: dependencies.modelContext)

    private lazy var transferRecordUseCase: TransferRecordUseCase =
        .init(repository: transferRecordRepository)

    private lazy var cycleRecordUseCase: CycleRecordUseCase =
        .init(repository: cycleRecordRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeProcedureRecordViewModel() -> ProcedureRecordViewModel {
        ProcedureRecordViewModel(
            transferRecordUseCase: transferRecordUseCase,
            cycleRecordUseCase: cycleRecordUseCase
        )
    }
}
