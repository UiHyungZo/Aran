//
//  AppDIContainer.swift
//  Aran
//

import SwiftData

@MainActor
final class AppDIContainer {
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    private lazy var appConfigurations = AppConfigurations()
    private lazy var drugRepositoryOverride = UITestEnvironment.makeDrugRepositoryOverride()

    lazy var calendarScene = CalendarSceneDIContainer(dependencies: .init(modelContext: modelContext))
    lazy var medicationScene = MedicationSceneDIContainer(dependencies: .init(
        modelContext: modelContext,
        drugServiceKey: appConfigurations.drugAPIDecoding,
        drugAPIEndpoint: appConfigurations.drugAPIEndpoint,
        drugApprovalServiceKey: appConfigurations.drugAPIPrdtDecoding,
        drugApprovalAPIEndpoint: appConfigurations.drugAPIPrdtEndpoint,
        drugRepositoryOverride: drugRepositoryOverride
    ))
    lazy var healthRecordScene = HealthRecordSceneDIContainer(dependencies: .init(modelContext: modelContext))
    lazy var procedureRecordScene = ProcedureRecordSceneDIContainer(dependencies: .init(modelContext: modelContext))
    lazy var drugInfoScene = DrugInfoSceneDIContainer(dependencies: .init(
        modelContext: modelContext,
        drugServiceKey: appConfigurations.drugAPIDecoding,
        drugAPIEndpoint: appConfigurations.drugAPIEndpoint,
        drugApprovalServiceKey: appConfigurations.drugAPIPrdtDecoding,
        drugApprovalAPIEndpoint: appConfigurations.drugAPIPrdtEndpoint,
        drugRepositoryOverride: drugRepositoryOverride
    ))

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
}
