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

| Entity             | Purpose                         |
| ------------------ | ------------------------------- |
| CycleRecord        | 날짜별 이벤트 기록 (1일 1레코드)             |
| DayEvent           | CycleRecord 내 이벤트 타입 (6종)        |
| TransferRecord     | 배아이식 상세 기록 (embryoGrade, result) |
| Medication         | 복용 약 및 주사                        |
| MedicationSchedule | 복용 시간 및 기간                        |
| HealthRecord       | 검사 수치 (10종)                       |
| DiaryEntry         | 감정 기록 (CycleRecord embedded)      |
| Drug               | 외부 API 약 정보                       |

---

# CycleRecord

날짜별 IVF 이벤트 기록.

Calendar Feature 요구사항에 따라 날짜 중심 설계를 채택.
1개 날짜 = 1개 CycleRecord, 해당 날짜에 발생한 이벤트 목록과 감정 일기를 포함.

---

## Responsibility

포함 정보:

* 날짜
* 이벤트 목록 (DayEvent 배열)
* 감정 일기 (embedded DiaryEntry)

---

## Domain Entity

```swift
struct CycleRecord: Identifiable {
    let id: UUID
    var date: Date
    var events: [DayEvent]
    var diary: DiaryEntry?
}

enum DayEvent {
    case hospitalVisit(note: String?)
    case ovulation
    case periodStart
    case embryoRetrieval(count: Int)
    case embryoTransfer(transferID: UUID)  // 상세 정보는 TransferRecord 참조
    case medication(medicationID: UUID)
}
```

---

## Rules

규칙:

* 날짜 중심 모델 유지 (1일 1레코드)
* 이벤트 목록은 JSON 직렬화 (DayEventDTO)로 저장
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

```swift
struct TransferRecord: Identifiable {
    let id: UUID
    var date: Date
    var embryoGrade: String
    var embryoCount: Int
    var transferType: TransferType  // fresh / frozen
    var result: TransferResult
}
```

---

## TransferResult

```swift
enum TransferResult: String {
    case pending = "대기"
    case success = "성공"
    case failed = "실패"
}
```

---

## Note

CycleRecord의 `DayEvent.embryoTransfer(transferID:)`가 이 레코드를 UUID로 참조.
Calendar에서 이벤트 점(dot)을 표시하고, 상세 화면에서 TransferRecord를 별도 로드.

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

```swift
struct Medication: Identifiable {
    let id: UUID
    var drugName: String
    var dosage: String
    var type: MedicationType   // 경구 / 주사 / 패치 / 기타
    var schedule: MedicationSchedule
    var isEnabled: Bool
    var notificationIDs: [String]
    var createdAt: Date
}

enum MedicationType: String, CaseIterable {
    case oral = "경구"
    case injection = "주사"
    case patch = "패치"
    case other = "기타"
}
```

> component(성분명)는 Phase 2 확장 예정.

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

```swift
struct MedicationSchedule {
    var times: [Date]       // 복용 시간 목록 (날짜 부분 무시, 시간만 사용)
    var startDate: Date
    var endDate: Date?
}
```

notificationIDs는 Medication 레벨에서 flat 배열로 관리.

---

## Rules

규칙:

* notificationIDs는 Medication 삭제 시 함께 제거
* 수정 시 기존 notification 제거 후 재등록
* schedule별 개별 ON/OFF는 Phase 2에서 구현 예정

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

```swift
struct HealthRecord: Identifiable {
    let id: UUID
    var testItem: TestItem
    var value: Double           // 수치 (수치 연산 가능하도록 Double 사용)
    var date: Date
    var note: String?
    var pgtResult: PGTResult?   // PGT 검사 전용 추가 결과
}

struct PGTResult {
    var normal: Int
    var abnormal: Int
    var mosaic: Int
}
```

---

## TestItem

10종 검사 항목 지원.

```swift
enum TestItem: String, CaseIterable {
    case fsh = "FSH"
    case amh = "AMH"
    case afc = "AFC"
    case e2 = "E2"
    case progesterone = "P4"
    case lh = "LH"
    case beta_hcg = "β-hCG"
    case pgt = "PGT"
    case chromosomeCouple = "부부염색체"
    case implantation = "착상 관련"
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

감정 기록. CycleRecord에 embedded.

날짜별로 1개의 감정 기록을 저장. 독립 Entity가 아니라 CycleRecord 내부 struct로 관리.

이유: 날짜 기준 조회로 충분하고 EmotionType enum보다 자유로운 emoji 입력이 UX에 더 적합.

---

## Responsibility

포함 정보:

* 이모지 (선택)
* 텍스트

---

## Domain Entity

```swift
struct DiaryEntry {
    var emoji: String?
    var text: String
}
```

날짜 정보는 상위 CycleRecord.date에서 관리.

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

```text
CycleRecord.events[.embryoTransfer(transferID: UUID)]
    → TransferRecord (UUID 참조)
```

이유:

* CycleRecord는 날짜 중심 이벤트 모델 (Calendar용)
* TransferRecord는 배아이식 상세 데이터 저장소
* 두 모델은 UUID로 느슨하게 연결 (SwiftData 직접 relationship 미사용)

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
