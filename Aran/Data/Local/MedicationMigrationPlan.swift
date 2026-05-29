import Foundation
import SwiftData

// SchemaV1: MedicationTimeSlotModel 없음, timeSlotID 없음
enum AppSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        CycleRecordModel.self,
        AppSchemaV1.MedicationModel.self,
        AppSchemaV1.MedicationLogModel.self,
        HealthRecordModel.self,
        TransferRecordModel.self,
        PGTRecordModel.self,
    ]

    @Model final class MedicationModel {
        @Attribute(.unique) var id: UUID
        var drugName: String
        var dosage: String
        var component: String
        var typeRawValue: String
        var scheduleTimes: [Date]
        var scheduleStartDate: Date
        var scheduleEndDate: Date?
        var isEnabled: Bool
        var notificationIDs: [String]
        var createdAt: Date

        init(
            id: UUID = UUID(),
            drugName: String = "",
            dosage: String = "",
            component: String = "",
            typeRawValue: String = "",
            scheduleTimes: [Date] = [],
            scheduleStartDate: Date = Date(),
            scheduleEndDate: Date? = nil,
            isEnabled: Bool = true,
            notificationIDs: [String] = [],
            createdAt: Date = Date()
        ) {
            self.id = id
            self.drugName = drugName
            self.dosage = dosage
            self.component = component
            self.typeRawValue = typeRawValue
            self.scheduleTimes = scheduleTimes
            self.scheduleStartDate = scheduleStartDate
            self.scheduleEndDate = scheduleEndDate
            self.isEnabled = isEnabled
            self.notificationIDs = notificationIDs
            self.createdAt = createdAt
        }
    }

    @Model final class MedicationLogModel {
        @Attribute(.unique) var id: UUID
        var medicationId: UUID
        var logDate: Date
        var isTaken: Bool
        var timeIndex: Int

        init(
            id: UUID = UUID(),
            medicationId: UUID = UUID(),
            logDate: Date = Date(),
            isTaken: Bool = false,
            timeIndex: Int = 0
        ) {
            self.id = id
            self.medicationId = medicationId
            self.logDate = logDate
            self.isTaken = isTaken
            self.timeIndex = timeIndex
        }
    }
}

// SchemaV2: MedicationTimeSlotModel 추가, timeSlotID 추가
enum AppSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] = [
        CycleRecordModel.self,
        MedicationModel.self,
        MedicationTimeSlotModel.self,
        MedicationLogModel.self,
        HealthRecordModel.self,
        TransferRecordModel.self,
        PGTRecordModel.self,
    ]
}

// SchemaV3: 즐겨찾기 약 저장 모델 추가
enum AppSchemaV3: VersionedSchema {
    static let versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] = [
        CycleRecordModel.self,
        MedicationModel.self,
        MedicationTimeSlotModel.self,
        MedicationLogModel.self,
        HealthRecordModel.self,
        TransferRecordModel.self,
        PGTRecordModel.self,
        FavoriteDrugModel.self,
    ]
}

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [AppSchemaV1.self, AppSchemaV2.self, AppSchemaV3.self]
    static var stages: [MigrationStage] = [migrateV1ToV2, migrateV2ToV3]

    // scheduleTimes 배열 → MedicationTimeSlotModel 관계로 변환
    static let migrateV1ToV2 = MigrationStage.custom(
        fromVersion: AppSchemaV1.self,
        toVersion: AppSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            let medications = try context.fetch(FetchDescriptor<MedicationModel>())
            for medication in medications where medication.timeSlots.isEmpty {
                medication.timeSlots = medication.scheduleTimes.map { time in
                    MedicationTimeSlotModel(
                        time: time,
                        isEnabled: medication.isEnabled,
                        medication: medication
                    )
                }
            }
            try context.save()
        }
    )

    static let migrateV2ToV3 = MigrationStage.lightweight(
        fromVersion: AppSchemaV2.self,
        toVersion: AppSchemaV3.self
    )
}
