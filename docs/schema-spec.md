# SwiftData Schema Spec

기준 날짜: 2026-05-30  
기준 코드: `Aran/Data/Local/*.swift`, `Aran/Data/Local/MedicationMigrationPlan.swift`

## Runtime Schema 포함 모델 (`AppSchemaV4.models`)

- `CycleRecordModel`
- `MedicationModel`
- `MedicationTimeSlotModel`
- `MedicationLogModel`
- `HealthRecordModel`
- `TransferRecordModel`
- `PGTRecordModel`
- `FavoriteDrugModel`

## 추가 `@Model` 정의 (현재 Runtime Schema 미포함)

- `DiaryEntryModel`
- `HospitalVisitModel`
- `MenstrualCycleModel`

## Table Spec

| Model | Field | Type | Optional | Unique | Relationship / Rule | Default | Note |
|---|---|---|---|---|---|---|---|
| `CycleRecordModel` | `id` | `UUID` | N | Y | - | `UUID()` | PK 성격 |
|  | `cycleNumber` | `Int` | N | N | - | `1` | 차수 |
|  | `date` | `Date` | N | N | - | 없음 | 기준 날짜 |
|  | `retrievalCount` | `Int` | N | N | - | `0` | 채취 수 |
|  | `fertilizedCount` | `Int` | N | N | - | `0` | 수정 수 |
|  | `frozenCount` | `Int` | N | N | - | `0` | 동결 수 |
|  | `embryoRecordsRaw` | `String` | N | N | - | `"[]"` | JSON 문자열 |
|  | `eventsData` | `Data` | N | N | - | `Data()` | JSON 바이너리 |
|  | `diaryEmoji` | `String` | Y | N | - | `nil` | 감정 이모지 |
|  | `diaryText` | `String` | Y | N | - | `nil` | 감정 텍스트 |
| `TransferRecordModel` | `id` | `UUID` | N | Y | - | `UUID()` | PK 성격 |
|  | `cycleNumber` | `Int` | N | N | - | `1` | Cycle 참조용 값 |
|  | `date` | `Date` | N | N | - | 없음 | 이식일 |
|  | `embryoGrade` | `String` | N | N | - | 없음 | 배아 등급 |
|  | `embryoCount` | `Int` | N | N | - | 없음 | 이식 개수 |
|  | `transferTypeRawValue` | `String` | N | N | - | 없음 | enum raw |
|  | `resultRawValue` | `String` | N | N | - | 없음 | enum raw |
|  | `memo` | `String` | Y | N | - | `nil` | 메모 |
| `PGTRecordModel` | `id` | `UUID` | N | Y | - | `UUID()` | PK 성격 |
|  | `cycleRecordId` | `UUID` | N | N | - | 없음 | Cycle FK 성격(명시 관계 아님) |
|  | `testDate` | `Date` | N | N | - | 없음 | 검사일 |
|  | `typeRawValue` | `String` | N | N | - | 없음 | enum raw |
|  | `normalCount` | `Int` | N | N | - | 없음 | 정상 |
|  | `abnormalCount` | `Int` | N | N | - | 없음 | 비정상 |
|  | `mosaicCount` | `Int` | N | N | - | 없음 | 모자이크 |
|  | `inconclusiveCount` | `Int` | N | N | - | `0` | 판정불가 |
|  | `resultStatusRawValue` | `String` | Y | N | - | `nil` | 공통 결과 상태 |
|  | `femaleChromosomeResultRawValue` | `String` | Y | N | - | `nil` | 부부염색체 여성 결과 |
|  | `maleChromosomeResultRawValue` | `String` | Y | N | - | `nil` | 부부염색체 남성 결과 |
|  | `implantationTestTypeRawValue` | `String` | Y | N | - | `nil` | 반착검사 종류 |
|  | `implantationResultRawValue` | `String` | Y | N | - | `nil` | 반착검사 결과 |
|  | `recommendedTransferWindow` | `String` | Y | N | - | `nil` | 권장 이식 창 |
|  | `memo` | `String` | Y | N | - | `nil` | 메모 |
| `MedicationModel` | `id` | `UUID` | N | Y | - | `UUID()` | PK 성격 |
|  | `drugName` | `String` | N | N | - | 없음 | 약 이름 |
|  | `dosage` | `String` | N | N | - | 없음 | 용량 |
|  | `component` | `String` | N | N | - | `""` | 성분 |
|  | `typeRawValue` | `String` | N | N | - | 없음 | enum raw |
|  | `scheduleTimes` | `[Date]` | N | N | - | 없음 | 레거시 필드 |
|  | `timeSlots` | `[MedicationTimeSlotModel]` | N | N | `@Relationship(deleteRule: .cascade, inverse: medication)` | `[]` | 1:N |
|  | `scheduleStartDate` | `Date` | N | N | - | 없음 | 시작일 |
|  | `scheduleEndDate` | `Date` | Y | N | - | `nil` | 종료일 |
|  | `isEnabled` | `Bool` | N | N | - | `true` | 활성화 |
|  | `notificationIDs` | `[String]` | N | N | - | `[]` | 알림 식별자 |
|  | `createdAt` | `Date` | N | N | - | `Date()` | 생성일 |
| `MedicationTimeSlotModel` | `id` | `UUID` | N | Y | - | `UUID()` | PK 성격 |
|  | `time` | `Date` | N | N | - | 없음 | 복용 시각 |
|  | `isEnabled` | `Bool` | N | N | - | `true` | 슬롯 활성화 |
|  | `medication` | `MedicationModel` | Y | N | inverse 대상 | `nil` | N:1 |
| `MedicationLogModel` | `id` | `UUID` | N | Y | - | `UUID()` | PK 성격 |
|  | `medicationId` | `UUID` | N | N | - | 없음 | Medication FK 성격(명시 관계 아님) |
|  | `logDate` | `Date` | N | N | - | 없음 | 복용 체크 날짜 |
|  | `isTaken` | `Bool` | N | N | - | 없음 | 복용 여부 |
|  | `timeSlotID` | `UUID` | Y | N | - | `nil` | 슬롯 식별자 |
|  | `timeIndex` | `Int` | N | N | - | `0` | 레거시 필드 |
| `HealthRecordModel` | `id` | `UUID` | N | Y | - | `UUID()` | PK 성격 |
|  | `type` | `String` | N | N | - | 없음 | 검사 타입 |
|  | `value` | `Double` | N | N | - | 없음 | 수치 |
|  | `unit` | `String` | N | N | - | 없음 | 단위 |
|  | `recordDate` | `Date` | N | N | - | 없음 | 기록일 |
|  | `memo` | `String` | Y | N | - | `nil` | 메모 |
| `FavoriteDrugModel` | `itemSeq` | `String` | N | Y | - | 없음 | PK 성격(유니크 키) |
|  | `id` | `UUID` | N | N | - | `UUID()` | 내부 식별자 |
|  | `itemName` | `String` | N | N | - | 없음 | 약 이름 |
|  | `entpName` | `String` | N | N | - | 없음 | 업체명 |
|  | `component` | `String` | Y | N | - | `nil` | 성분 |
|  | `efcyQesitm` | `String` | Y | N | - | `nil` | 효능 |
|  | `useMethodQesitm` | `String` | Y | N | - | `nil` | 사용법 |
|  | `atpnWarnQesitm` | `String` | Y | N | - | `nil` | 주의경고 |
|  | `atpnQesitm` | `String` | Y | N | - | `nil` | 주의사항 |
|  | `intrcQesitm` | `String` | Y | N | - | `nil` | 상호작용 |
|  | `seQesitm` | `String` | Y | N | - | `nil` | 부작용 |
|  | `depositMethodQesitm` | `String` | Y | N | - | `nil` | 보관법 |
|  | `itemImage` | `String` | Y | N | - | `nil` | 이미지 URL |
|  | `createdAt` | `Date` | N | N | - | `Date()` | 생성일 |
| `DiaryEntryModel` | `id` | `UUID` | N | Y | - | `UUID()` | 현재 스키마 미포함 |
|  | `date` | `Date` | N | N | - | 없음 |  |
|  | `emoji` | `String` | Y | N | - | `nil` |  |
|  | `content` | `String` | N | N | - | 없음 |  |
| `HospitalVisitModel` | `id` | `UUID` | N | Y | - | `UUID()` | 현재 스키마 미포함 |
|  | `visitDate` | `Date` | N | N | - | 없음 |  |
|  | `visitTypes` | `[String]` | N | N | - | 없음 | 복수 타입 |
|  | `memo` | `String` | Y | N | - | `nil` |  |
| `MenstrualCycleModel` | `id` | `UUID` | N | Y | - | `UUID()` | 현재 스키마 미포함 |
|  | `startDate` | `Date` | N | N | - | 없음 |  |
|  | `cycleLength` | `Int` | N | N | - | `28` |  |

## Migration Version Summary

- `v1.0.0`: `MedicationTimeSlotModel` 없음, `MedicationLogModel.timeSlotID` 없음
- `v2.0.0`: `MedicationTimeSlotModel` 추가, `MedicationLogModel.timeSlotID` 반영
- `v3.0.0`: `FavoriteDrugModel` 추가
- `v4.0.0`: `PGTRecordModel` 검사별 결과 상세 필드 추가
