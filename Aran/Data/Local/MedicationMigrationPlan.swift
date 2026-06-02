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
        AppSchemaV1.PGTRecordModel.self,
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

    @Model final class PGTRecordModel {
        @Attribute(.unique) var id: UUID
        var cycleRecordId: UUID
        var testDate: Date
        var typeRawValue: String
        var normalCount: Int
        var abnormalCount: Int
        var mosaicCount: Int
        var memo: String?

        init(
            id: UUID = UUID(),
            cycleRecordId: UUID = UUID(),
            testDate: Date = Date(),
            typeRawValue: String = "",
            normalCount: Int = 0,
            abnormalCount: Int = 0,
            mosaicCount: Int = 0,
            memo: String? = nil
        ) {
            self.id = id
            self.cycleRecordId = cycleRecordId
            self.testDate = testDate
            self.typeRawValue = typeRawValue
            self.normalCount = normalCount
            self.abnormalCount = abnormalCount
            self.mosaicCount = mosaicCount
            self.memo = memo
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
        AppSchemaV2.PGTRecordModel.self,
    ]

    @Model final class PGTRecordModel {
        @Attribute(.unique) var id: UUID
        var cycleRecordId: UUID
        var testDate: Date
        var typeRawValue: String
        var normalCount: Int
        var abnormalCount: Int
        var mosaicCount: Int
        var memo: String?

        init(
            id: UUID = UUID(),
            cycleRecordId: UUID = UUID(),
            testDate: Date = Date(),
            typeRawValue: String = "",
            normalCount: Int = 0,
            abnormalCount: Int = 0,
            mosaicCount: Int = 0,
            memo: String? = nil
        ) {
            self.id = id
            self.cycleRecordId = cycleRecordId
            self.testDate = testDate
            self.typeRawValue = typeRawValue
            self.normalCount = normalCount
            self.abnormalCount = abnormalCount
            self.mosaicCount = mosaicCount
            self.memo = memo
        }
    }
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
        AppSchemaV3.PGTRecordModel.self,
        FavoriteDrugModel.self,
    ]

    @Model final class PGTRecordModel {
        @Attribute(.unique) var id: UUID
        var cycleRecordId: UUID
        var testDate: Date
        var typeRawValue: String
        var normalCount: Int
        var abnormalCount: Int
        var mosaicCount: Int
        var memo: String?

        init(
            id: UUID = UUID(),
            cycleRecordId: UUID = UUID(),
            testDate: Date = Date(),
            typeRawValue: String = "",
            normalCount: Int = 0,
            abnormalCount: Int = 0,
            mosaicCount: Int = 0,
            memo: String? = nil
        ) {
            self.id = id
            self.cycleRecordId = cycleRecordId
            self.testDate = testDate
            self.typeRawValue = typeRawValue
            self.normalCount = normalCount
            self.abnormalCount = abnormalCount
            self.mosaicCount = mosaicCount
            self.memo = memo
        }
    }
}

// SchemaV4: PGT/염색체/반착검사 결과 상세 필드 추가
enum AppSchemaV4: VersionedSchema {
    static let versionIdentifier = Schema.Version(4, 0, 0)

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

// SchemaV5: 캘린더 관련 모델(HospitalVisit/Diary/MenstrualCycle) 스키마 등록
enum AppSchemaV5: VersionedSchema {
    static let versionIdentifier = Schema.Version(5, 0, 0)

    static var models: [any PersistentModel.Type] = [
        CycleRecordModel.self,
        MedicationModel.self,
        MedicationTimeSlotModel.self,
        MedicationLogModel.self,
        HealthRecordModel.self,
        TransferRecordModel.self,
        PGTRecordModel.self,
        FavoriteDrugModel.self,
        HospitalVisitModel.self,
        DiaryEntryModel.self,
        MenstrualCycleModel.self,
    ]
}

// SchemaV6: 약 정보 최근 검색어 스키마 등록
enum AppSchemaV6: VersionedSchema {
    static let versionIdentifier = Schema.Version(6, 0, 0)

    static var models: [any PersistentModel.Type] = [
        CycleRecordModel.self,
        MedicationModel.self,
        MedicationTimeSlotModel.self,
        MedicationLogModel.self,
        HealthRecordModel.self,
        TransferRecordModel.self,
        PGTRecordModel.self,
        FavoriteDrugModel.self,
        HospitalVisitModel.self,
        DiaryEntryModel.self,
        MenstrualCycleModel.self,
        RecentDrugSearchModel.self,
    ]
}

enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [AppSchemaV1.self, AppSchemaV2.self, AppSchemaV3.self, AppSchemaV4.self, AppSchemaV5.self, AppSchemaV6.self]
    static var stages: [MigrationStage] = [migrateV1ToV2, migrateV2ToV3, migrateV3ToV4, migrateV4ToV5, migrateV5ToV6]

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

    static let migrateV3ToV4 = MigrationStage.lightweight(
        fromVersion: AppSchemaV3.self,
        toVersion: AppSchemaV4.self
    )

    static let migrateV4ToV5 = MigrationStage.lightweight(
        fromVersion: AppSchemaV4.self,
        toVersion: AppSchemaV5.self
    )

    static let migrateV5ToV6 = MigrationStage.lightweight(
        fromVersion: AppSchemaV5.self,
        toVersion: AppSchemaV6.self
    )
}
