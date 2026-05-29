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

    lazy var calendarScene = CalendarSceneDIContainer(dependencies: .init(modelContext: modelContext))
    lazy var medicationScene = MedicationSceneDIContainer(dependencies: .init(
        modelContext: modelContext,
        drugServiceKey: appConfigurations.drugAPIDecoding,
        drugAPIEndpoint: appConfigurations.drugAPIEndpoint
    ))
    lazy var healthRecordScene = HealthRecordSceneDIContainer(dependencies: .init(modelContext: modelContext))
    lazy var procedureRecordScene = ProcedureRecordSceneDIContainer(dependencies: .init(modelContext: modelContext))
    lazy var drugInfoScene = DrugInfoSceneDIContainer(dependencies: .init(
        modelContext: modelContext,
        drugServiceKey: appConfigurations.drugAPIDecoding,
        drugAPIEndpoint: appConfigurations.drugAPIEndpoint
    ))

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
}
