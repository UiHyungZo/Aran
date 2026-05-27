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
* 약물/주사 추적 (날짜별 복용 체크 포함)
* 검사 수치 기록
* 배아이식/채취 기록
* 의약품 정보 검색
* 면접에서 설명 가능한 Clean Architecture 구현

이 앱은 범용 헬스케어 앱이 아니라 IVF 치료 흐름에 특화된 앱이다.

포트폴리오 프로젝트이므로 과도한 추상화보다 명확성을 우선한다.

---

# 기술 스택

* Swift 6
* UIKit + RxSwift
* SwiftUI + Combine
* Clean Architecture + MVVM
* SwiftData
* Swift Charts
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
* Presentation은 Repository 구현체를 직접 참조하지 않는다.
* 사용 사례가 1개뿐인 과도한 추상화는 지양한다.
* 포트폴리오 목적상 readability와 explicit naming을 우선한다.

---

# Feature Stack 규칙

## SwiftUI Feature (Combine 사용)

대상:

* 📅 캘린더
* 🗂 시술 기록 — Swift Charts 포함
* 🔍 약 정보

## UIKit Feature (RxSwift 사용)

대상:

* 💊 약/주사
* 🏥 검사

## Reactive 규칙

* Feature 내부에서 RxSwift와 Combine을 혼합하지 않는다.
* 브리징은 UIHostingController / UIViewRepresentable처럼 명확한 목적이 있을 때만 허용한다.

---

# Swift 6 / Concurrency 규칙

* UI 관련 ViewModel은 `@MainActor` 사용
* RxSwift 연동부는 필요한 범위에서만 `@preconcurrency` 허용
* async/await는 Repository 또는 UseCase 내부에서 사용
* 불필요한 MainActor hopping을 지양한다.
* Sendable 경고 억제를 남용하지 않는다.

---

# API 규칙

* Router는 Alamofire `URLRequestConvertible` 사용
* API Key는 configuration으로 관리
* DTO는 Data Layer에서 decode
* DTO → Domain Entity 변환 후 반환
* Empty Result는 정상 UX Case로 처리
* Network Error는 retry 1회 → fallback 상태 제공

Base URL: `https://apis.data.go.kr/1471000/DrbEasyDrugInfoService`

---

# 테스트 원칙

Clean Architecture 선택 이유를 테스트 가능성으로 증명한다.

* 스타일: `given → when → then`
* Mock Repository 기반 UseCase 테스트 우선
* 전 레이어 테스트: UseCase / Repository / Network / ViewModel / UI

---

# 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16 Pro'
```

---

# 상세 문서

작업 시작 전 반드시 `docs/`를 확인한다.

* `docs/architecture.md`
* `docs/features.md`
* `docs/api.md`
* `docs/coding-style.md`
* `docs/testing.md`
* `docs/concurrency.md`
* `docs/data-model.md`
* `docs/roadmap.md`
* `docs/ADR.md`
* `docs/UI_GUIDE.md`

---

# 트리거

### Build
- "build the app"
  → `bash scripts/build-debug.sh` 실행 후 결과 리포트

### Test
- "run tests"
  → `xcodebuild test -scheme Aran -destination ...` 실행 후 실패 원인 분석

### Next Task
- "next task" / "다음 작업 진행해줘" / "TODO 다음 거 해줘"
  → `TODO.md` 미완료 항목 확인 후 구현 계획과 변경 파일 제시

### Feature 구현
- "감정 일기 구현해줘" / "병원 일정 구현해줘" / "생리 주기 구현해줘"
  → `docs/features.md`, `docs/data-model.md` 확인 후 계획 제시, 승인 후 구현
- "시술 기록 구현해줘" / "CycleRecord 구현해줘"
  → `docs/features.md`, `docs/architecture.md`, `docs/UI_GUIDE.md` 확인 후 계획 제시
- "Swift Charts 추가해줘"
  → `docs/features.md`, `docs/UI_GUIDE.md` 확인 후 계획 제시
- "복용 체크 구현해줘" / "MedicationLog 구현해줘"
  → `docs/data-model.md`, `docs/features.md` 확인 후 계획 제시

### Scope Check
- "이거 PRD 범위야?"
  → `docs/PRD.md`, `docs/features.md` 기준으로 판단
