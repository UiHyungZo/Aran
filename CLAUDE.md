# CLAUDE.md

Claude Code는 작업 시작 전에 반드시 이 파일을 먼저 읽는다.

세부 구현 규칙은 `docs/` 문서를 참고한다.

---

# 절대 규칙

* 항상 한국어로 응답한다.
* 비사소한 수정 전에는 반드시 구현 계획과 변경 예정 파일을 먼저 설명한다.
* 사용자 승인 없이 다음 작업을 수행하지 않는다:

  * 파일 삭제
  * 파일/타입 이름 변경
  * Bundle Identifier 변경
  * Xcode Project 설정 수정
  * 외부 라이브러리 추가
* API Key, Secret, 개인정보를 하드코딩하지 않는다.
* 변경 사항은 작고 리뷰 가능하게 유지한다.
* 요구사항이 모호하면 구현 전에 질문한다.
* `CLAUDE.md` 규칙이 `docs/`보다 우선한다.

---

# 프로젝트 개요

Aran은 IVF 치료 관리용 iOS 포트폴리오 앱이다.

핵심 목적:

* IVF 치료 일정 관리
* 약물/주사 추적
* 검사 수치 기록
* 배아이식/채취 기록
* 의약품 정보 검색
* 면접에서 설명 가능한 Clean Architecture 구현

이 앱은 범용 헬스케어 앱이 아니라 IVF 치료 흐름에 특화된 앱이다.

포트폴리오 프로젝트이므로 과도한 추상화보다 명확성을 우선한다.

---

# 기술 스택

* Swift
* UIKit + RxSwift
* SwiftUI + Combine
* Clean Architecture + MVVM
* SwiftData
* Alamofire
* async/await
* UserNotifications
* XCTest / XCUITest
* Swift Package Manager

---

# 아키텍처 원칙

## 의존성 방향

```text
Presentation -> Domain <- Data
Application -> Presentation
Application -> Data
Application -> Infrastructure
Data -> Infrastructure
```

## 규칙

* Domain은 UIKit, SwiftUI, RxSwift, Combine, Alamofire, SwiftData에 의존하지 않는다.
* ViewModel은 UseCase를 통해서만 비즈니스 로직을 실행한다.
* Repository 구현체는 Data Layer에만 존재한다.
* DTO와 Domain Entity는 반드시 분리한다.
* Infrastructure는 외부 기술 세부사항을 캡슐화한다.
* Presentation은 Repository 구현체를 직접 참조하지 않는다.
* 사용 사례가 1개뿐인 과도한 추상화는 지양한다.
* 포트폴리오 목적상 readability와 explicit naming을 우선한다.

---

# Feature Stack 규칙

## SwiftUI Feature

* Combine 사용
* 상태 기반 UI 구성
* View 내부 API 호출 금지

대상:

* Calendar
* Drug Information

## UIKit Feature

* RxSwift 사용
* Driver 기반 UI 바인딩 우선
* ViewController 내부 비즈니스 로직 금지

대상:

* Medication / Injection
* Health Record

## Reactive 규칙

* Feature 내부에서 RxSwift와 Combine을 혼합하지 않는다.
* 브리징은 명확한 목적이 있을 때만 허용한다.

허용 예시:

* UIHostingController
* UIViewRepresentable

---

# Swift 6 / Concurrency 규칙

* UI 관련 ViewModel은 `@MainActor` 사용
* RxSwift 연동부는 필요한 범위에서만 `@preconcurrency` 허용
* async/await는 Repository 또는 UseCase 내부에서 사용
* 불필요한 MainActor hopping을 지양한다.
* Sendable 경고 억제를 남용하지 않는다.

---

# API 규칙

외부 API:

* MFDS e약은요 OpenAPI

Base URL:

* https://apis.data.go.kr/1471000/DrbEasyDrugInfoService

규칙:

* Router는 Alamofire `URLRequestConvertible` 사용
* API Key는 configuration으로 관리
* DTO는 Data Layer에서 decode
* DTO → Domain Entity 변환 후 반환
* Empty Result는 정상 UX Case로 처리
* Network Error는 retry/fallback 상태 제공

---

# 도메인 우선순위

핵심 도메인:

* IVF Cycle
* Medication Schedule
* Injection Record
* Lab Result
* Embryo Transfer
* Retrieval Record
* Emotional Diary

우선순위:

1. 치료 일정
2. 약물 추적
3. 검사 기록
4. IVF 치료 흐름 시각화

범용 건강관리 기능은 우선순위가 낮다.

---

# 테스트 원칙

목표:

Clean Architecture 선택 이유를 테스트 가능성으로 증명한다.

우선 테스트 대상:

* UseCase
* ViewModel
* Repository

테스트 스타일:

```text
given -> when -> then
```

Mock Repository 기반 테스트를 우선한다.

---

# 빌드 / 테스트

## Build

```bash
xcodebuild -scheme Aran
```

## Test

```bash
xcodebuild test -scheme Aran
```

---

# 상세 문서

작업 시작 전 반드시 `docs/`를 확인한다.

* docs/architecture.md
* docs/features.md
* docs/api.md
* docs/coding-style.md
* docs/testing.md
* docs/concurrency.md
* docs/data-model.md
* docs/roadmap.md
* docs/decisions.md


## 트리거

### Build

- "build the app"
  → `xcodebuild -scheme Aran` 실행 후 결과 리포트

### Test

- "run tests"
  → `xcodebuild test -scheme Aran` 실행 후 실패 원인 분석

### Next Task

- "next task"
- "다음 작업 진행해줘"
- "TODO 다음 거 해줘"
  → `TODO.md`의 최상단 미완료 작업 확인 후 구현 계획과 변경 파일 제시

### Feature

- "약 검색 구현해줘"
- "Calendar 구현해줘"
  → 관련 `docs/` 확인 후 계획 제시, 승인 후 구현

### Scope Check

- "이거 MVP 범위야?"
  → `docs/roadmap.md`, `docs/features.md` 기준으로 MVP / Backlog / Phase 2 판단
