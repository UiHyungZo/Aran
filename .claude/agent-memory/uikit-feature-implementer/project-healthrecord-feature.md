---
name: project-healthrecord-feature
description: HealthRecord(검사) 탭 UIKit+RxSwift 4개 화면 구현 완료 — 패턴, 폴더 구조, 주의사항 기록
metadata:
  type: project
---

HealthRecord 탭 4개 화면 전부 구현 완료 (2026-05-22).

**Why:** 포트폴리오 앱 IVF 치료 관리의 검사 수치 추적 기능. Clean Architecture + MVVM + RxSwift 패턴 증명 목적.

**How to apply:** 이후 HealthRecord Feature 관련 작업 시 아래 패턴을 그대로 따를 것.

## 구현된 파일 목록

### Domain
- `Domain/Entities/HealthRecord.swift` — pgtResult 필드, isNumeric/category computed property 추가
- `Domain/UseCases/HealthRecordUseCase.swift` — savePGT(), fetchLatestPerItem() 추가

### Data
- `Data/Local/HealthRecordModel.swift` — pgtNormal/pgtAbnormal/pgtMosaic optional 필드 추가
- `Data/Local/Mappers/HealthRecordMapper.swift` — PGT 필드 양방향 변환

### Presentation (신규)
- `Presentation/HealthRecord/HealthRecordViewModel.swift` — TestItemSummary, ExamSection typealias
- `Presentation/HealthRecord/ExamListCell.swift` — 수치형/PGT형 분기 셀, PGTChipView 내부 private 클래스
- `Presentation/HealthRecord/ExamListViewController.swift` — insetGrouped TableView, 2섹션
- `Presentation/HealthRecord/HealthRecordFormViewModel.swift` — 수치 입력 유효성 검사 (Double 파싱)
- `Presentation/HealthRecord/HealthRecordFormViewController.swift` — bottom sheet, chip 스크롤, debug chip
- `Presentation/HealthRecord/PGTFormViewModel.swift` — totalCount > 0 조건
- `Presentation/HealthRecord/PGTFormViewController.swift` — UIStepper 3개 (정상/이상/모자이크)
- `Presentation/HealthRecord/ExamHistoryViewModel.swift` — item을 init으로 받음, private extension으로 .item 프로퍼티
- `Presentation/HealthRecord/ExamHistoryViewController.swift` — ExamHistoryHeaderView(BarChartView), ExamHistoryCell, ExamHistoryActions 포함

### Application
- `Application/HealthRecordFlowCoordinator.swift` — ExamListActions, showAddFormSelection()에서 ActionSheet로 수치/PGT 분기
- `Application/DIContainer/HealthRecordSceneDIContainer.swift` — 4개 factory 메서드 구현

## 핵심 패턴 결정사항

- ExamHistoryActions는 ExamHistoryViewController.swift 내부에 정의 (MedicationListActions처럼 Coordinator 파일에 두지 않고, 히스토리 화면 전용이라 해당 파일에 위치)
- BarChartView는 UIView 상속, draw(_:) 오버라이드로 외부 라이브러리 없이 구현
- UIView에는 isLayoutMarginsRelativeArrangement 없음 — UIStackView에만 적용 가능
- contentEdgeInsets deprecated (iOS 15+) — 경고만 발생, 기존 MedicationFormViewController도 동일하게 사용 중이므로 일관성 유지
- Driver.combineLatest로 latestSummary + trendText 동시 반영
