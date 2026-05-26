---
name: debug
description: >
  빌드 에러, 테스트 실패, 런타임 크래시, 아키텍처 위반을 진단하고 수정하는 스킬.
  "로그 분석해줘", "빌드 안돼", "테스트 실패해", "크래시 났어", "에러 원인 찾아줘" 같은 요청에 사용한다.
  swift 컴파일 에러, RxSwift/Combine 연동 문제, SwiftData 크래시, SPM 의존성 오류를 다룬다.
  심층 분석이 필요하면 ios-error-analyzer 에이전트로 위임한다.
---

# Debug Skill

## 목적

빌드 에러, 테스트 실패, 런타임 크래시를 **최소 파일 탐색**으로 진단하고
**안전하고 작은 수정 방향**을 제안한다.

심층 근본 원인 분석이 필요한 경우 `ios-error-analyzer` 에이전트에 위임한다.

---

## 실행 순서

### 1단계: 에러 분류

에러 로그를 보고 아래 유형 중 하나로 분류한다:

| 유형 | 대표 증상 |
|------|-----------|
| Swift 컴파일 에러 | `cannot find type`, `value of type X has no member Y`, `cannot convert value` |
| Concurrency 위반 | `sending X risks causing data races`, `@MainActor` 누락 |
| RxSwift 문제 | `disposed`, `BehaviorRelay type mismatch`, Driver 바인딩 오류 |
| Combine 문제 | `@Published` 타입 불일치, `sink` 메모리 누수 |
| SwiftData 크래시 | `modelContainer` 중복, `@Model` 관계 오류 |
| SPM 의존성 | `Package.resolved` 충돌, 버전 불일치 |
| 테스트 실패 | Mock 불일치, 비동기 타이밍, `given/when/then` 설정 오류 |
| 아키텍처 위반 | Domain에 UIKit import, Presentation에서 Repository 직접 참조 |

### 2단계: 최소 파일 탐색

에러 메시지에서 직접 언급된 파일과 라인만 먼저 확인한다.

```bash
# 빌드 에러 로그에서 파일/라인 추출
xcodebuild test -scheme Aran 2>&1 | grep "error:" | head -20

# 특정 타입 참조 위치 확인
grep -rn "TypeName" Aran/ --include="*.swift"

# Domain 레이어 금지 import 확인
grep -rn "import UIKit\|import SwiftUI\|import RxSwift\|import Combine" \
  Aran/Domain/ --include="*.swift"
```

연쇄 에러는 **첫 번째 에러**를 먼저 해결한다.

### 3단계: 수정 방향 제안

수정 제안 시 반드시:
- 수정 파일명과 예상 라인 번호 명시
- 변경 전 / 변경 후 코드 스니펫 제공
- 영향 범위 설명
- 사용자 승인 요청

---

## 자주 발생하는 패턴

### SwiftData modelContainer 중복

```swift
// ❌ SceneDelegate와 ContentView 양쪽에 .modelContainer 설정
// ✅ AppDIContainer 또는 SceneDelegate 한 곳에서만 주입
```

### RxSwift Driver vs Observable 타입 불일치

```swift
// ❌ Observable을 Driver 바인딩에 직접 연결
// ✅ .asDriver(onErrorJustReturn: ...) 변환 후 바인딩
```

### @MainActor 누락 (Swift 6)

```swift
// ❌ UI ViewModel에 @MainActor 없음 → data race 경고
// ✅ class CalendarViewModel: ObservableObject { @MainActor ... }
```

### Domain에 외부 프레임워크 import

```swift
// ❌ Domain/UseCases/MedicationUseCase.swift 에 import RxSwift
// ✅ Domain은 순수 Swift만 사용, RxSwift는 ViewModel 계층에서만
```

### Mock Repository 타입 불일치

```swift
// ❌ MockRepository가 Protocol의 최신 메서드를 구현하지 않음
// ✅ Protocol 변경 시 Mock 동기화 필수 확인
```

---

## 심층 분석이 필요한 경우

아래 상황에서는 `ios-error-analyzer` 에이전트에 위임한다:

- 에러 원인이 여러 파일에 걸쳐 있는 경우
- SPM 의존성 충돌로 Package.resolved 분석이 필요한 경우
- 연쇄 에러가 10개 이상이고 첫 원인을 특정하기 어려운 경우
- Xcode 프로젝트 설정(pbxproj) 문제가 의심되는 경우

---

## 출력 형식

```
### 🔍 에러 유형
[분류]

### 📍 원인
[근본 원인 — 표면 증상이 아닌 실제 원인]

### 🛠️ 수정 방향
파일: `경로` (라인: XX)
// 변경 전 → 변경 후

### ⚠️ 영향 범위
[다른 파일/기능에 미치는 영향]

### ✅ 다음 단계
[승인 요청 포함]
```
