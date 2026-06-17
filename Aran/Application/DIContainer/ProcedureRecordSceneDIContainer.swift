//
//  ProcedureRecordSceneDIContainer.swift
//  Aran
//

import SwiftData
import AranDomain

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

    private lazy var pgtRecordRepository: PGTRecordRepositoryProtocol =
        PGTRecordRepository(context: dependencies.modelContext)

    private lazy var transferRecordUseCase: TransferRecordUseCaseProtocol =
        TransferRecordUseCase(repository: transferRecordRepository)

    private lazy var cycleRecordUseCase: CycleRecordUseCaseProtocol =
        CycleRecordUseCase(repository: cycleRecordRepository)

    private lazy var pgtRecordUseCase: PGTRecordUseCaseProtocol =
        PGTRecordUseCase(repository: pgtRecordRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeProcedureRecordViewModel() -> ProcedureRecordViewModel {
        ProcedureRecordViewModel(
            transferRecordUseCase: transferRecordUseCase,
            cycleRecordUseCase: cycleRecordUseCase,
            pgtRecordUseCase: pgtRecordUseCase
        )
    }
}
