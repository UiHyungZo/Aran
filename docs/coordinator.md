# Coordinator 패턴 가이드

## 개요

Coordinator 패턴은 화면 전환 로직을 View/ViewController에서 분리해 중앙에서 관리하는 패턴이다.

UIKit은 명령형 navigation(`pushViewController`, `present`)이라 Coordinator가 자연스럽게 맞는다.
SwiftUI는 선언형 navigation(`NavigationStack`, `@State`)을 기본으로 제공하므로, 무조건 Coordinator를 도입하는 게 아니라 필요한 상황에서만 써야 한다.

---

## SwiftUI에서 Coordinator가 적합한 3가지 상황

### 1. 딥링크 / 외부 진입이 복잡할 때

push notification, URL scheme 등으로 여러 화면을 순서대로 쌓거나 조건에 따라 다른 경로로 진입해야 할 때.

```
push notification → 특정 약물 상세 → 복용 기록 폼
URL scheme → 특정 날짜 캘린더 → 일기 편집
```

View 내부 `@State`만으로는 외부에서 경로를 통째로 설정하기 어렵다. Coordinator가 `NavigationPath`를 들고 있으면 외부에서 경로를 한 번에 주입할 수 있다.

### 2. 전체 화면 스택을 교체해야 할 때

인증 흐름처럼 조건에 따라 완전히 다른 화면 스택을 보여줘야 할 때.

```
미로그인 → 온보딩 스택
로그인 완료 → 메인 탭 스택으로 교체
세션 만료 → 로그인 화면으로 리셋
```

개별 View가 전환을 처리하면 책임이 분산돼 엣지 케이스가 생긴다. Coordinator가 "어떤 스택을 보여줄지"를 외부에서 결정하는 게 맞다.

### 3. 여러 Feature가 공유하는 화면이 있을 때

동일한 목적지 화면으로 진입하는 경로가 여럿일 때.

```
캘린더 → 약물 상세
시술 기록 → 약물 상세
약 정보 검색 → 약물 상세
```

각 View에 중복 navigation 로직이 생긴다. 공통 Coordinator가 목적지만 받아서 라우팅하면 중복을 제거할 수 있다.

---

## Coordinator가 적합하지 않은 경우

단순 `.sheet` / `NavigationLink` 수준의 전환은 Coordinator 없이도 명확하고 간결하다.
SwiftUI의 선언형 상태 관리가 이미 그 역할을 충분히 한다.

- 딥링크 없음
- 스택 교체 없음
- 공유 목적지 없음

이 세 가지가 없으면 Coordinator는 오버엔지니어링이다.

---

## 이 프로젝트(Aran) 적용 현황

| Feature | Framework | Coordinator | 화면 전환 방식 |
|---------|-----------|:-----------:|---------------|
| 약/주사 (Medication) | UIKit | ✅ | `MedicationFlowCoordinator` |
| 검사 (HealthRecord) | UIKit | ✅ | `HealthRecordFlowCoordinator` |
| 캘린더 (Calendar) | SwiftUI | ❌ | `.sheet` / `.fullScreenCover` + `@State` |
| 시술 기록 (ProcedureRecord) | SwiftUI | ❌ | `NavigationStack` + `NavigationLink` + `.sheet` |
| 약 정보 (DrugInfo) | SwiftUI | ❌ | 단순 View 조합 |

SwiftUI Feature는 위 3가지 상황에 해당하지 않으므로 native navigation을 유지한다.
UIKit Feature의 Coordinator는 `Application/` 폴더에 위치하며, DI Container를 통해 주입된다.
