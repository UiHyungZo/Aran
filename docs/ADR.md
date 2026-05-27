# Architecture Decision Records

## ADR-001: Clean Architecture + MVVM을 사용한다
**결정**: Presentation, Domain, Data, Infrastructure 계층을 분리한다. ViewModel은 UseCase를 통해 비즈니스 로직을 실행한다.

**이유**: 포트폴리오 프로젝트에서 책임 분리, 테스트 가능성, 면접 설명 가능성이 중요하다.

**트레이드오프**: 단순 CRUD 화면에서는 파일 수가 늘어날 수 있다. 단, 과도한 추상화는 피하고 사용 사례가 명확한 경우에만 계층을 추가한다.

## ADR-002: UIKit Feature는 RxSwift, SwiftUI Feature는 Combine을 사용한다
**결정**: Medication/Injection, Health Record는 UIKit + RxSwift를 우선하고 Calendar, Drug Information은 SwiftUI + Combine을 우선한다.

**이유**: 두 UI 패러다임과 reactive stack을 모두 보여주되 Feature 내부 혼합을 막아 복잡도를 제한한다.

**트레이드오프**: 브리징 지점이 필요할 수 있다. 브리징은 UIHostingController, UIViewRepresentable처럼 명확한 목적이 있을 때만 허용한다.

## ADR-003: API Key는 코드에 하드코딩하지 않는다
**결정**: API Key, Secret, 개인정보는 configuration 또는 로컬 환경 파일로 관리한다.

**이유**: 저장소 유출 위험을 방지하고 포트폴리오 코드 품질을 유지한다.

**트레이드오프**: 로컬 실행 전 환경 설정 단계가 필요하다.

## ADR-004: 시술 기록 탭은 SwiftUI + Combine을 사용한다
**결정**: CycleRecord / TransferRecord / PGT 탭은 SwiftUI + Combine + Swift Charts로 구현한다.

**이유**: 차수 카드 목록과 Swift Charts 시각화가 SwiftUI 선언형 방식에 자연스럽게 맞기 때문이다. UIKit + RxSwift는 Medication/HealthRecord 탭에서 이미 증명하므로 중복 구현할 필요가 없다.

**트레이드오프**: CalendarSceneDIContainer 등 기존 SwiftUI 탭과 패턴을 통일해야 한다.

