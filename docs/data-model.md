# Data Model

## Goal

Aran의 데이터 모델은 IVF 치료 흐름을 중심으로 설계한다.

목표:

* IVF cycle 흐름 기록 가능
* 약 복용 시간과 알림을 독립적으로 관리
* Domain Entity와 Persistence Model 분리
* SwiftData 의존성을 Domain에서 제거
* 테스트 가능한 Entity 구조 유지

이 프로젝트는 “범용 헬스케어 모델”보다 IVF 치료 관리 흐름에 최적화된 모델을 우선한다.

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

# Core Domain

Aran의 핵심 도메인:

* IVF Cycle
* Medication
* Medication Schedule
* Embryo Transfer
* Retrieval Record
* Health Record
* Emotional Diary

---

# Entity Overview

| Entity             | Purpose     |
| ------------------ | ----------- |
| CycleRecord        | 차수별 IVF 기록  |
| TransferRecord     | 배아이식 기록     |
| Medication         | 복용 약        |
| MedicationSchedule | 복용 시간       |
| HealthRecord       | 검사 수치       |
| DiaryEntry         | 감정 기록       |
| Drug               | 외부 API 약 정보 |

---

# CycleRecord

IVF 차수 기록.

예시:

```text id="ebyn1p"
1차 시술
채취 10개
수정 7개
동결 4개
```

---

## Responsibility

포함 정보:

* 차수 번호
* 시작일
* 채취 개수
* 수정 개수
* 동결 개수
* 배아 등급
* 이식 기록

---

## Domain Entity

```swift id="6wuh79"
struct CycleRecord {
    let id: UUID
    let cycleNumber: Int
    let startDate: Date
    let retrievalCount: Int
    let fertilizedCount: Int
    let frozenCount: Int
    let embryoGrades: [String]
    let transfers: [TransferRecord]
}
```

---

## Rules

규칙:

* IVF 흐름 중심 모델 유지
* 계산 로직은 UseCase에서 수행
* UI formatting 포함 금지

---

# TransferRecord

배아이식 기록.

---

## Responsibility

포함 정보:

* 이식일
* 배아 등급
* 배아 개수
* 신선/동결 여부
* 결과 상태

---

## Domain Entity

```swift id="jlwmvv"
struct TransferRecord {
    let id: UUID
    let transferDate: Date
    let embryoGrade: String
    let embryoCount: Int
    let isFresh: Bool
    let result: TransferResult
}
```

---

## TransferResult

예시:

```swift id="iut4mz"
enum TransferResult {
    case pending
    case success
    case failed
}
```

---

# Medication

복용 약 또는 주사.

---

## Responsibility

포함 정보:

* 약 이름
* 용량
* 성분명
* 활성 상태
* 복용 일정

---

## Domain Entity

```swift id="zjlwmg"
struct Medication {
    let id: UUID
    let name: String
    let dosage: String
    let component: String?
    let isActive: Bool
    let schedules: [MedicationSchedule]
}
```

---

# MedicationSchedule

복용 시간 및 알림 정보.

---

## Why Separate Schedule

Medication과 MedicationSchedule을 분리한다.

이유:

* 약 하나가 여러 복용 시간을 가질 수 있음
* 시간마다 notificationId가 다름
* 시간마다 ON/OFF 상태가 다름

예시:

```text id="zq0nx6"
프로게스테론
├── 오전 9시
└── 오후 9시
```

---

## Domain Entity

```swift id="t8f6pw"
struct MedicationSchedule {
    let id: UUID
    let hour: Int
    let minute: Int
    let isNotificationEnabled: Bool
    let notificationId: String
}
```

---

## Rules

규칙:

* notificationId는 schedule 단위 관리
* 수정 시 기존 notification 제거 후 재등록
* Medication 삭제 시 schedule 함께 제거

---

# HealthRecord

검사 수치 기록.

---

## Responsibility

포함 정보:

* 검사 타입
* 수치
* 날짜
* 메모

---

## Domain Entity

```swift id="0e7u0w"
struct HealthRecord {
    let id: UUID
    let recordDate: Date
    let type: HealthRecordType
    let value: String
    let memo: String?
}
```

---

## HealthRecordType

예시:

```swift id="9o2dpr"
enum HealthRecordType {
    case fsh
    case amh
    case afc
    case e2
    case progesterone
}
```

---

## Rules

규칙:

* value formatting은 UI에서 수행
* Trend 계산은 UseCase에서 수행
* 숫자 validation은 ViewModel에서 처리

---

# DiaryEntry

감정 기록.

---

## Responsibility

포함 정보:

* 날짜
* 감정 상태
* 텍스트 내용

---

## Domain Entity

```swift id="j8jz5t"
struct DiaryEntry {
    let id: UUID
    let date: Date
    let emotion: EmotionType
    let content: String
}
```

---

## EmotionType

예시:

```swift id="d72o5d"
enum EmotionType {
    case happy
    case anxious
    case sad
    case hopeful
    case tired
}
```

---

# Drug

외부 API 기반 약 정보.

---

## Responsibility

포함 정보:

* 약 이름
* 회사명
* 효능
* 용법
* 주의사항

---

## Domain Entity

```swift id="5krk9i"
struct Drug {
    let name: String
    let company: String
    let efficacy: String?
    let usage: String?
    let warning: String?
}
```

---

## Rules

규칙:

* DTO를 직접 사용하지 않는다.
* API field naming을 Entity에 노출하지 않는다.
* Entity는 앱 내부 표현 중심으로 유지한다.

---

# SwiftData Model Policy

SwiftData Model은 persistence 전용이다.

예시:

```swift id="4c2z4l"
@Model
final class MedicationModel {

}
```

---

# Persistence Model Rules

금지:

* UI formatting 포함
* business logic 포함
* View 직접 전달
* DTO 혼합

허용:

* relationship
* persistence metadata
* local storage field

---

# Relationship Policy

## Medication ↔ MedicationSchedule

관계:

```text id="rghvvv"
Medication
1:N
MedicationSchedule
```

이유:

* 복수 시간 지원
* schedule별 notification 관리

---

## CycleRecord ↔ TransferRecord

관계:

```text id="7tl7pa"
CycleRecord
1:N
TransferRecord
```

이유:

* 차수별 여러 이식 기록 관리 가능

---

# Mapper Policy

Mapper는 변환 책임만 가진다.

예시:

```text id="ikg2od"
DTO
→ Entity

Model
→ Entity

Entity
→ Model
```

---

# Mapper Rules

허용:

* nil handling
* enum conversion
* optional conversion

금지:

* UI formatting
* business logic
* network call

---

# DTO Separation Policy

절대 혼합 금지.

금지 예시:

```text id="f6zq9j"
DrugItemDTO
→ View 직접 전달
```

반드시:

```text id="l8tr8r"
DTO
→ Mapper
→ Entity
→ ViewModel
```

---

# Persistence Flow

저장 흐름:

```text id="6yqvvw"
ViewModel
→ UseCase
→ Repository
→ Mapper
→ SwiftData Model
→ SwiftData
```

조회 흐름:

```text id="ck4kzb"
SwiftData
→ Model
→ Mapper
→ Entity
→ UseCase
→ ViewModel
```

---

# Local Storage Policy

MVP 기준:

로컬 저장:

* SwiftData 사용
* iCloud sync 미지원
* multi-device sync 미지원

---

# Deletion Policy

삭제 규칙:

| Entity             | Behavior        |
| ------------------ | --------------- |
| Medication         | schedule 함께 제거  |
| MedicationSchedule | notification 제거 |
| CycleRecord        | transfer 함께 제거  |
| HealthRecord       | 단순 삭제           |
| DiaryEntry         | 단순 삭제           |

---

# Notification Data Policy

notificationId는 schedule 기준 관리한다.

예시:

```swift id="3f7qly"
notificationId
```

규칙:

* UUID 기반 생성 가능
* 수정 시 기존 notification 제거
* notification과 persistence 상태 일치 유지

---

# Search Data Policy

DrugSearch 결과는 persistence하지 않는다.

이유:

* MVP 범위 최소화
* API 기반 조회 중심
* local cache complexity 방지

Phase 2에서 캐시 검토 가능.

---

# Validation Policy

validation 책임:

| Layer     | Responsibility      |
| --------- | ------------------- |
| ViewModel | 입력 validation       |
| UseCase   | business validation |
| Model     | persistence only    |

---

# Future Expansion

Phase 2 확장 가능 영역:

* MenstrualCycle
* OvulationPrediction
* PGTResult
* Health Trend Graph
* Medication Statistics
* Cloud Sync

MVP에서는 포함하지 않는다.

---

# Testability Policy

Entity는 테스트 가능한 구조 유지.

규칙:

* 순수 Swift 타입 유지
* framework dependency 제거
* deterministic state 유지

Mock 생성이 쉬워야 한다.

좋은 예시:

```swift id="ln2fli"
let medication = Medication(
    id: UUID(),
    name: "프로게스테론",
    dosage: "200mg",
    component: "Progesterone",
    isActive: true,
    schedules: []
)
```

---

# Portfolio Principles

이 프로젝트의 데이터 모델은 “IVF 흐름 중심 설계”를 설명 가능하게 만드는 데 목적이 있다.

면접에서 설명 가능한 포인트:

* 왜 MedicationSchedule을 분리했는가
* 왜 DTO / Entity / Model을 나눴는가
* 왜 SwiftData Model을 직접 노출하지 않는가
* 왜 Domain Entity를 순수 Swift로 유지했는가
* 왜 IVF cycle 중심 구조를 선택했는가

우선순위:

1. 명확한 책임 분리
2. 테스트 가능성
3. 유지보수성
4. 설명 가능한 구조
5. 확장 가능성
