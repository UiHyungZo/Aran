# Phase 003: Swift Charts — 검사 수치 트렌드 차트

## 목표
- Health Record(검사) 탭에 항목별 수치 변화 Line Chart를 추가한다.
- PRD v13.0 TAB 4 기능 완성.

## 참조 문서
- `CLAUDE.md`
- `docs/features.md`
- `docs/UI_GUIDE.md`

## 작업 범위
- `ExamHistoryViewController` 상단 또는 별도 차트 뷰에 Swift Charts Line Chart 추가
- 항목별 수치 변화 Line Chart
- 정상 범위 레퍼런스 라인 (RuleMark)
- 다크모드 색상 별도 정의

> 현재 `ExamHistoryViewController`에 `BarChartView`(직접 구현)가 있음.
> Swift Charts로 교체 또는 병행할지 먼저 확인 후 진행.

## 변경 예정 파일
- `Aran/Presentation/HealthRecord/ExamHistoryViewController.swift` (수정)
- `Aran/Presentation/HealthRecord/ExamTrendChartView.swift` (신규 — SwiftUI Chart, UIHostingController로 브리징)

## 완료 조건
- [ ] 항목별 수치 시간순 Line Chart 표시
- [ ] 정상 범위 레퍼런스 라인 표시
- [ ] 다크모드 색상 정상 적용

## 상태
pending
