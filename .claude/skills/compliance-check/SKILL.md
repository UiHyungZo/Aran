---
name: compliance-check
description: >
  CLAUDE.md 규칙 준수 여부를 검증하는 스킬. 코드 변경 후, PR 전, 새 Feature 구현 후 언제든지 실행한다.
  "CLAUDE.md 규칙 맞아?", "아키텍처 맞게 된 거야?", "규칙 위반 없어?", "구현이 계획에 맞아?" 같은 요청에 반드시 이 스킬을 사용한다.
  검사 항목: 레이어 의존성 방향, RxSwift/Combine 혼용, ViewController 내 비즈니스 로직, DTO/Entity 미분리, API Key 하드코딩.
  결과는 PASS / FAIL 판정 + 위반 항목 요약으로 출력한다.
---

# CLAUDE.md Compliance Check

## 목적

현재 변경된 파일이 `CLAUDE.md`의 규칙을 준수하는지 빠르게 검증한다.
변경 규모가 클수록 위반이 눈에 띄지 않기 쉬우므로, 구조적 규칙을 자동으로 점검한다.

---

## 실행 순서

### 1. 검사 대상 파일 수집

```bash
# 현재 브랜치에서 변경된 Swift 파일 목록
git diff --name-only HEAD~1 HEAD -- '*.swift' 2>/dev/null || git diff --name-only -- '*.swift'
# 또는 스테이지된 파일
git diff --cached --name-only -- '*.swift'
```

파일이 없으면 현재 브랜치 전체 변경분(`git diff main...HEAD`)을 사용한다.
사용자가 특정 파일이나 디렉토리를 지정한 경우 그것을 우선한다.

### 2. 5가지 규칙 검사

아래 규칙을 **순서대로** 검사하고, 각 항목마다 위반 여부를 기록한다.

---

#### 규칙 1: 레이어 의존성 방향

**원칙**: `Presentation → Domain ← Data`. Domain은 외부 프레임워크에 의존하지 않는다.

검사 방법:
```bash
# Domain 레이어 파일에서 금지된 import 검색
grep -rn "import UIKit\|import SwiftUI\|import RxSwift\|import Combine\|import Alamofire\|import SwiftData" \
  <변경된 파일 중 */Domain/* 경로>
```

위반 예시:
- `Domain/UseCase/*.swift`에 `import RxSwift` 있음
- `Domain/Entity/*.swift`에 `import SwiftData` 있음

추가 검사:
```bash
# Presentation이 Repository 구현체를 직접 참조하는지 확인
grep -rn "Repository()\|RepositoryImpl\|DefaultRepository" \
  <변경된 파일 중 */Presentation/* 경로>
```

---

#### 규칙 2: RxSwift / Combine 혼용 금지

**원칙**: UIKit Feature는 RxSwift만, SwiftUI Feature는 Combine만 사용한다.

Feature별 허용 프레임워크:
- `Presentation/Medication/`, `Presentation/HealthRecord/` → RxSwift만 허용
- `Presentation/Calendar/`, `Presentation/DrugInfo/` → Combine만 허용

검사 방법:
```bash
# UIKit Feature 내 Combine 사용 여부
grep -rn "import Combine\|@Published\|PassthroughSubject\|CurrentValueSubject" \
  <Presentation/Medication, Presentation/HealthRecord 경로 파일들>

# SwiftUI Feature 내 RxSwift 사용 여부
grep -rn "import RxSwift\|import RxCocoa\|BehaviorRelay\|PublishRelay" \
  <Presentation/Calendar, Presentation/DrugInfo 경로 파일들>
```

단, `UIHostingController`, `UIViewRepresentable` 브리징은 허용한다.

---

#### 규칙 3: ViewController 내 비즈니스 로직 금지

**원칙**: ViewController는 UseCase를 호출할 뿐, 직접 비즈니스 로직을 처리하지 않는다.

검사 방법:
```bash
# ViewController 파일에서 Repository 직접 참조 또는 네트워크 호출 감지
grep -rn "Repository\|Alamofire\|URLSession\|AF\.request\|\.map\|\.filter\|\.reduce" \
  <변경된 파일 중 *ViewController.swift>
```

위반 예시:
- ViewController 내에 `repository.fetch()` 직접 호출
- ViewController 내에 데이터 변환 로직 (map, filter 등) 존재
- UseCase 없이 Repository를 직접 주입받는 ViewController

주의: RxSwift의 UI 바인딩용 `.map`은 ViewModel에서 발생하면 허용한다.

---

#### 규칙 4: DTO / Domain Entity 분리

**원칙**: DTO는 Data Layer에만 존재하며, Domain Entity와 반드시 분리한다.

검사 방법:
```bash
# Domain/Entity 경로에 DTO 타입 존재 여부
grep -rn "DTO\|Response\|Request" <*/Domain/Entity/* 경로>

# Data Layer 외부에서 DTO 직접 참조 여부
grep -rn "DTO" <*/Presentation/* 또는 */Domain/* 경로>
```

위반 예시:
- `Domain/Entity/DrugEntity.swift`에 `struct DrugDTO` 정의
- `Presentation/ViewModel`에서 DTO를 직접 사용

---

#### 규칙 5: API Key 하드코딩 금지

```bash
# API Key, Secret 패턴 검색
grep -rn "serviceKey\s*=\s*\"[A-Za-z0-9+/=]\{20,\}\"\|apiKey\s*=\s*\"[^\"]" \
  <모든 변경 파일>
```

위반 예시:
- Swift 파일에 직접 API Key 문자열 리터럴 포함
- Configuration 파일 대신 코드에 하드코딩

---

### 3. 결과 출력

아래 형식으로 간결하게 출력한다:

```
## CLAUDE.md Compliance Check

**판정: PASS ✓** (또는 **FAIL ✗**)

| 규칙 | 결과 |
|------|------|
| 레이어 의존성 | ✓ PASS |
| RxSwift/Combine 혼용 | ✗ FAIL |
| VC 비즈니스 로직 | ✓ PASS |
| DTO/Entity 분리 | ✓ PASS |
| API Key 하드코딩 | ✓ PASS |

### 위반 사항
- [FAIL] **RxSwift/Combine 혼용**: `Calendar/ViewModel/CalendarViewModel.swift:12` — `import RxSwift` (SwiftUI Feature에서 금지)
```

FAIL이 하나라도 있으면 전체 판정은 **FAIL**이다.
모든 항목이 PASS면 `위반 사항` 섹션은 생략한다.

---

## 주의사항

- 검사는 **변경된 파일 범위**에 한정한다. 전체 코드베이스를 스캔하지 않는다.
- 파일 경로 기반으로 레이어를 추론한다 (`/Domain/`, `/Data/`, `/Presentation/` 등).
- grep 결과가 없으면 해당 규칙은 PASS로 처리한다.
- 애매한 경우(브리징, 허용된 예외)는 PASS로 처리하고 주석으로 언급한다.
