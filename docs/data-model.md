# Data Model

## Goal

Aran의 데이터 모델은 IVF 치료 흐름을 중심으로 설계한다.

목표:

* IVF cycle 흐름 기록 가능
* 약 복용 시간과 알림을 독립적으로 관리
* 날짜별 복용 완료 체크 기록 (MedicationLog)
* Domain Entity와 Persistence Model 분리
* SwiftData 의존성을 Domain에서 제거
* 테스트 가능한 Entity 구조 유지

이 프로젝트는 "범용 헬스케어 모델"보다 IVF 치료 관리 흐름에 최적화된 모델을 우선한다.

---

# Architecture Policy

데이터 모델은 다음 3단계로 분리한다.

```text
Persistence Model
→ Mapper
→ Domain Entity
```

예시:

```text
MedicationModel
→ MedicationMapper
→ Medication
```

규칙:

* SwiftData Model을 Presentation으로 직접 전달하지 않는다.
* SwiftData Model을 UseCase에서 직접 사용하지 않는다.
* DTO와 SwiftData Model을 혼합하지 않는다.
* Domain Entity는 순수 Swift 타입 유지한다.

---

# Entity Overview

| Entity | Purpose |
|--------|---------|
| CycleRecord | IVF 차수별 채취/수정/동결 기록 |
| TransferRecord | 배아이식 상세 기록 |
| PGTRecord | PGT/염색체/반착검사 결과 기록 |
| Medication | 복용 약 및 주사 |
| MedicationSchedule | 복용 시간 및 알림 |
| MedicationLog | 날짜별 복용 완료 체크 기록 (v14 신규) |
| HealthRecord | 검사 수치 (기본 7개 + 커스텀) |
| DiaryEntry | 감정 기록 |
| HospitalVisit | 병원 일정 (복수 종류 지원) |
| MenstrualCycle | 생리 주기 및 배란 예정일 |
| Drug | 외부 API 약 정보 |

---

# CycleRecord

차수별 IVF 기록.

---

## Domain Entity

```swift
struct CycleRecord: Identifiable {
    let id: UUID
    var cycleNumber: Int
    var startDate: Date
    var retrievalCount: Int
    var fertilizedCount: Int
    var frozenCount: Int
    var embryoGrades: [String]
}
```

관계:

* 1:N → TransferRecord
* 1:N → PGTRecord

---

# TransferRecord

배아이식 기록.

---

## Domain Entity

```swift
struct TransferRecord: Identifiable {
    let id: UUID
    var cycleRecordId: UUID
    var transferDate: Date
    var embryoGrade: String
    var embryoCount: Int
    var isFresh: Bool
    var result: TransferResult
}

enum TransferResult: String {
    case pending = "대기"
    case success = "성공"
    case failed  = "실패"
}
```

---

# PGTRecord

PGT / 염색체 / 반착검사 기록.

시술 기록 탭에서 관리. 검사 탭(HealthRecord)과 분리.

---

## Domain Entity

```swift
struct PGTRecord: Identifiable {
    let id: UUID
    var cycleRecordId: UUID
    var testDate: Date
    var type: PGTType
    var normalCount: Int
    var abnormalCount: Int
    var mosaicCount: Int
    var memo: String?
}

enum PGTType: String {
    case pgtA             = "PGT-A"
    case pgtM             = "PGT-M"
    case chromosomeCouple = "부부염색체"
    case implantation     = "반착검사"
}
```

---

# Medication

복용 약 또는 주사.

---

## Domain Entity

```swift
struct Medication: Identifiable {
    let id: UUID
    var name: String
    var dosage: String
    var component: String?
    var isActive: Bool
    var notificationIDs: [String]
    var createdAt: Date
}
```

---

# MedicationSchedule

복용 시간 및 알림 정보.

## Why Separate Schedule

* 약 하나가 여러 복용 시간을 가질 수 있음
* 시간마다 notificationId가 다름
* 시간마다 ON/OFF 상태가 다름

## Domain Entity

```swift
struct MedicationSchedule: Identifiable {
    let id: UUID
    var medicationId: UUID
    var hour: Int
    var minute: Int
    var isNotificationEnabled: Bool
    var notificationId: String
}
```

---

# MedicationLog ← v14 신규

날짜별 복용 완료 체크 기록.

## Responsibility

캘린더 1단계 시트에서 약 옆 체크박스로 당일 복용 완료를 토글하면 이 모델에 저장된다.

## Domain Entity

```swift
struct MedicationLog: Identifiable {
    let id: UUID
    var medicationId: UUID
    var logDate: Date       // 날짜만 사용 (시간 무시)
    var isTaken: Bool
}
```

## Rules

* 날짜별 · 약별 1레코드
* logDate는 날짜 단위로 저장 (시간 정규화)
* Medication 삭제 시 관련 MedicationLog 함께 삭제

---

# HealthRecord

검사 수치 기록.

v14.0부터 type 필드가 String으로 변경되어 커스텀 항목을 지원한다.

---

## Domain Entity

```swift
struct HealthRecord: Identifiable {
    let id: UUID
    var recordDate: Date
    var type: String        // 기본 7개 상수 또는 커스텀 이름
    var value: Double
    var unit: String
    var memo: String?
}
```

## 기본 항목 상수

```swift
enum HealthRecordType {
    static let fsh     = "FSH"
    static let amh     = "AMH"
    static let afc     = "AFC"
    static let e2      = "E2"
    static let p4      = "P4"
    static let lh      = "LH"
    static let betaHCG = "β-hCG"

    static let defaults: [String] = [fsh, amh, afc, e2, p4, lh, betaHCG]
}
```

## Rules

* type은 String — enum 미사용 (커스텀 항목 자유롭게 추가 가능)
* value formatting은 UI에서 수행
* Trend 계산은 UseCase에서 수행
* 숫자 validation은 ViewModel에서 처리

---

# DiaryEntry

감정 기록.

---

## Domain Entity

```swift
struct DiaryEntry: Identifiable {
    let id: UUID
    var date: Date
    var emoji: String?
    var content: String     // 최대 500자
}
```

---

# HospitalVisit

병원 일정. v14.0부터 복수 종류 선택 지원.

---

## Domain Entity

```swift
struct HospitalVisit: Identifiable {
    let id: UUID
    var visitDate: Date
    var visitTypes: [String]    // 복수 선택 (내원/채혈/초음파 등)
    var memo: String?
}
```

> v14 변경: `visitType: String` → `visitTypes: [String]`

---

# MenstrualCycle

생리 주기 및 배란 예정일.

---

## Domain Entity

```swift
struct MenstrualCycle: Identifiable {
    let id: UUID
    var startDate: Date
    var cycleLength: Int    // 기본 28일
}
```

배란 예정일 계산은 MenstrualCycleUseCase에서 수행:
`ovulationDate = startDate + (cycleLength - 14) days`

---

# Drug

외부 API 기반 약 정보.

---

## Domain Entity

```swift
struct Drug {
    let name: String
    let company: String
    let efficacy: String?
    let usage: String?
    let warning: String?
}
```

규칙:

* DTO를 직접 사용하지 않는다.
* API field naming을 Entity에 노출하지 않는다.

---

# SwiftData Model Policy

SwiftData Model은 persistence 전용이다.

금지:

* UI formatting 포함
* business logic 포함
* View 직접 전달
* DTO 혼합

---

# Relationship Policy

| 관계 | 타입 |
|------|------|
| CycleRecord → TransferRecord | 1:N |
| CycleRecord → PGTRecord | 1:N |
| Medication → MedicationSchedule | 1:N |
| Medication → MedicationLog | 1:N |

---

# Deletion Policy

| Entity | Behavior |
|--------|----------|
| Medication | MedicationSchedule + MedicationLog 함께 제거 |
| MedicationSchedule | notification 제거 |
| MedicationLog | 단순 삭제 |
| CycleRecord | TransferRecord + PGTRecord 함께 제거 |
| HealthRecord | 단순 삭제 |
| DiaryEntry | 단순 삭제 |
| HospitalVisit | 단순 삭제 |
| MenstrualCycle | 단순 삭제 |

---

# Persistence Flow

저장 흐름:

```text
ViewModel → UseCase → Repository → Mapper → SwiftData Model → SwiftData
```

조회 흐름:

```text
SwiftData → Model → Mapper → Entity → UseCase → ViewModel
```

---

# Testability Policy

Entity는 테스트 가능한 구조 유지.

규칙:

* 순수 Swift 타입 유지
* framework dependency 제거
* deterministic state 유지

---

# Portfolio Principles

면접에서 설명 가능한 포인트:

* 왜 MedicationSchedule을 분리했는가
* 왜 MedicationLog를 별도 모델로 분리했는가 (날짜별 복용 체크 독립 관리)
* 왜 HealthRecord.type을 enum에서 String으로 변경했는가 (커스텀 항목 확장)
* 왜 HospitalVisit.visitTypes를 배열로 변경했는가 (복수 종류 선택)
* 왜 DTO / Entity / Model을 나눴는가
* 왜 SwiftData Model을 직접 노출하지 않는가
