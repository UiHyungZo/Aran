# 🌸 아란 (Aran)

> 시험관 시술(IVF)을 진행 중인 여성을 위한 통합 관리 iOS 앱

<br>

## 📱 Preview

|               캘린더               |                약/주사               |              검사             |             약 정보            |
| :-----------------------------: | :-------------------------------: | :-------------------------: | :-------------------------: |
| ![](./screenshots/calendar.gif) | ![](./screenshots/medication.gif) | ![](./screenshots/exam.gif) | ![](./screenshots/drug.gif) |

<br>

## 📌 프로젝트 소개

시험관 시술 중인 사용자는:

* 복용 약 시간 관리
* 병원 일정 관리
* 채취/이식 기록
* 검사 수치 추적
* 감정 기록

등을 여러 앱과 메모에 분산 관리하는 경우가 많습니다.

아란(Aran)은 이러한 흐름을 하나의 캘린더 중심 구조로 통합한 iOS 앱입니다.

<br>

## 🧩 프로젝트 정보

| 항목    | 내용                                  |
| ----- | ----------------------------------- |
| 개발 기간 | 4주                                  |
| 개발 인원 | 1인 iOS 개발                           |
| 플랫폼   | iOS 17+                             |
| 언어    | Swift 6                             |
| 아키텍처  | Clean Architecture + MVVM           |
| UI    | SwiftUI + Combine / UIKit + RxSwift |
| 데이터   | SwiftData                           |
| 테스트   | XCTest + UseCase TDD                |

<br>

# ✨ 주요 기능

### 📅 캘린더

* 월간 캘린더 기반 일정 관리
* 날짜별 채취 / 이식 기록
* 날짜 상세 바텀시트
* 감정 일기 기록

### 💊 약 / 주사

* 복용 약 등록 및 관리
* 복용 시간별 알림 설정
* 스와이프 액션 (중단 / 삭제)
* 약 검색 후 자동 입력

### 🧪 검사

* FSH / AMH / AFC / E2 수치 기록
* 최신 수치 증감 표시
* 검사 히스토리 조회

### 🔍 약 정보

* e약은요 OpenAPI 기반 약 검색
* 효능 / 용법 / 주의사항 조회
* 약 등록 화면 연동

<br>

# 🏗 Architecture

```text
Presentation Layer
├── SwiftUI + Combine
│   ├── Calendar
│   └── DrugInfo
│
└── UIKit + RxSwift
    ├── Medication
    └── Exam
            ↓
Domain Layer
├── UseCase
├── Entity
└── Repository Protocol
            ↓
Data Layer
├── SwiftData
├── Alamofire
├── UserNotifications
└── Repository Implementation
```

<br>

# 🔥 Technical Challenges

## 1. DrugSearch 컴포넌트 재사용 설계

약 검색 기능은:

* 약 정보 탭에서는 `상세 조회`
* 약/주사 탭에서는 `등록`

플로우가 달랐습니다.

중복 화면을 만들지 않기 위해 `DrugSearchMode` 기반으로 동작을 분리했습니다.

```swift
enum DrugSearchMode {
    case browse
    case register
}
```

이를 통해:

* UI 재사용
* API 로직 재사용
* Flow 분기 최소화

를 달성했습니다.

---

## 2. SwiftUI + UIKit 브릿지 구성

앱은 탭별로 다른 UI 스택을 사용합니다.

| 탭          | 기술                |
| ---------- | ----------------- |
| 캘린더 / 약 정보 | SwiftUI + Combine |
| 약/주사 / 검사  | UIKit + RxSwift   |

SwiftUI 화면에서 UIKit FlowCoordinator를 연결하기 위해:

* UIHostingController
* UIViewControllerRepresentable
* Coordinator 패턴

을 사용해 브릿지 구조를 구성했습니다.

---

## 3. MedicationSchedule 1:N 분리 설계

초기에는 Medication 내부에 복용 시간을 배열로 저장하려 했습니다.

하지만:

* 시간별 알림 ON/OFF 상태
* notificationId 관리
* 특정 시간만 수정/삭제

요구사항이 생기며 Entity를 분리했습니다.

```text
Medication (1)
    └── MedicationSchedule (N)
```

결과적으로:

* 알림 수정 로직 단순화
* 시간 단위 상태 관리 가능
* UserNotifications 관리 안정화

를 얻을 수 있었습니다.

---

## 4. Swift 6 Concurrency 대응

RxSwift 연동 과정에서 Swift 6의 Sendable warning이 발생했습니다.

대응 방식:

```swift
@MainActor
final class MedicationViewModel: ObservableObject { }

@preconcurrency import RxSwift
@preconcurrency import RxCocoa
```

무분별한 warning suppression 대신:

* UI 계층에만 @MainActor 적용
* RxSwift import만 제한적으로 완화

하는 방식으로 점진 대응했습니다.

---

## 5. e약은요 API 폴백 처리

네트워크 실패 또는 검색 결과 없음 상황을 고려해:

```text
검색 성공
→ 약 자동 입력

검색 실패
→ retry 1회
→ 직접 입력 폴백
```

흐름으로 UX를 구성했습니다.

또한 `.debounce(0.3s)` 를 적용해 불필요한 API 호출을 줄였습니다.

<br>

# 🧪 Test Strategy

비즈니스 로직은 UseCase 단위로 분리하고 MockRepository 기반 TDD를 진행했습니다.

| UseCase                       | 테스트                   |
| ----------------------------- | --------------------- |
| CycleRecordUseCase            | 저장 / 조회 / 업데이트        |
| MedicationNotificationUseCase | 알림 등록 / 수정 / 삭제       |
| SearchDrugUseCase             | 검색 성공 / 빈 키워드 / 실패 전파 |
| HealthRecordUseCase           | 저장 / 조회 / 정렬          |

<br>

# 📁 Project Structure

```text
Aran/
├── Application/
├── Presentation/
│   ├── Calendar/
│   ├── Medication/
│   ├── Exam/
│   └── DrugInfo/
│
├── Domain/
│   ├── UseCases/
│   ├── Entities/
│   └── Repositories/
│
└── Data/
    ├── Repositories/
    ├── Network/
    └── Persistence/
```

<br>

# 🚀 실행 방법

```bash
git clone https://github.com/UiHyungZo/Aran.git
```

```bash
API_KEY = YOUR_API_KEY
```

```bash
open Aran.xcodeproj
```

<br>

# 🛠 Tech Stack

| 분야           | 기술                       |
| ------------ | ------------------------ |
| UI           | SwiftUI, UIKit           |
| Reactive     | Combine, RxSwift         |
| Architecture | Clean Architecture, MVVM |
| Storage      | SwiftData                |
| Network      | Alamofire                |
| Notification | UserNotifications        |
| Test         | XCTest                   |
| Dependency   | Swift Package Manager    |

<br>

# 📌 회고

아란 프로젝트를 통해:

* SwiftUI/UIKit 혼용 구조
* RxSwift와 Swift Concurrency 공존
* UseCase 기반 TDD
* 재사용 가능한 검색 컴포넌트 설계
* Notification 상태 관리

등을 실제 앱 구조 안에서 경험할 수 있었습니다.

---

<p align="center">
  Aran · IVF Care iOS App · 2026
</p>
