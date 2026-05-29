# CLAUDE.md

Claude Code는 작업 시작 전에 반드시 이 파일을 먼저 읽는다.

세부 구현 규칙은 `docs/` 문서를 참고한다.

---

# ✨ AI 코딩 에이전트 행동 지침 (Karpathy Guidelines)

Claude Code가 따라야 할 4가지 핵심 원칙. 프로젝트 규칙과 병렬로 적용된다.

## 1. 구현 전 사고 (Think Before Coding)

가정하지 않는다. 모호함을 숨기지 않는다. 트레이드오프를 명확히 밝힌다.

구현을 시작하기 전 다음을 준수한다:

- 자신의 가정을 명시적으로 기술한다. 불확실한 경우 질문한다.
- 해석의 여지가 여러 가지라면 임의로 선택하지 말고 대안들을 제시한다.
- 더 간단한 접근 방식이 있다면 제안한다. 정당한 사유가 있다면 사용자의 요청에 반대 의견을 제시한다.
- 불분명한 부분이 있다면 작업을 중단한다. 혼란스러운 부분을 구체적으로 언급하며 질문한다.

## 2. 단순성 우선 (Simplicity First)

- 문제를 해결하는 최소한의 코드만 작성한다. 추측에 기반한 코드는 배제한다.
- 요청되지 않은 기능은 추가하지 않는다.
- 일회성 코드를 위해 추상화 계층을 만들지 않는다.
- 요청되지 않은 유연성이나 설정 가능성을 고려하지 않는다.
- 발생 불가능한 시나리오에 대한 예외 처리를 하지 않는다.
- 200줄의 코드를 50줄로 줄일 수 있다면 코드를 다시 작성한다.
- "시니어 엔지니어가 보기에 이 코드가 지나치게 복잡한가?"라고 자문한다. 그렇다면 단순화한다.

## 3. 정밀한 수정 (Surgical Changes)

필요한 부분만 수정한다. 본인이 만든 코드의 뒷정리만 수행한다.

기존 코드를 편집할 때 다음을 준수한다:

- 인접한 코드, 주석, 포맷을 임의로 개선하지 않는다.
- 망가지지 않은 부분을 리팩토링하지 않는다.
- 본인의 스타일과 다르더라도 기존 스타일을 따른다.
- 작업과 무관한 데드 코드를 발견하면 보고하되 직접 삭제하지 않는다.

수정으로 인해 사용되지 않게 된 요소가 발생할 경우:

- 본인의 수정으로 인해 불필요해진 임포트, 변수, 함수는 제거한다.
- 기존에 존재하던 데드 코드는 요청이 없는 한 그대로 둔다.
- 테스트 기준: 변경된 모든 라인은 사용자의 요청사항과 직접적으로 연결되어야 한다.

## 4. 목표 중심 실행 (Goal-Driven Execution)

성공 기준을 정의한다. 검증될 때까지 반복한다.

작업을 검증 가능한 목표로 변환한다:

- "유효성 검사 추가" → "잘못된 입력에 대한 테스트 작성 후 통과 확인"
- "버그 수정" → "버그를 재현하는 테스트 작성 후 통과 확인"
- "X 리팩토링" → "리팩토링 전후의 테스트 통과 확인"

다단계 작업의 경우 간략한 계획을 수립한다:

1. [단계] → 검증: [확인 사항]
2. [단계] → 검증: [확인 사항]
3. [단계] → 검증: [확인 사항]

성공 기준이 명확해야 독립적인 작업이 가능하다. "작동하게 만들기"와 같은 모호한 기준은 불필요한 재질의를 야기한다.

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

* Router는 `URLComponents` 기반 순수 Foundation `URLRequest` 반환 (Alamofire 미의존)
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
