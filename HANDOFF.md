# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `feat/drugInjection`
- **전체 진행도**: MVP 1순위 기능 구현 완료 + 안정화 완료
- **다음 단계**: MVP 2순위 기능 (감정 일기, 병원 일정 등)

---

## 완료된 기능

| Feature | 스택 | 상태 |
|---------|------|------|
| Calendar | SwiftUI + Combine | ✅ 완료 |
| Medication / Injection | UIKit + RxSwift | ✅ 완료 |
| Health Record | UIKit + RxSwift | ✅ 완료 |
| Drug Information | SwiftUI + Combine | ✅ 완료 |
| Transfer / Retrieval Record | Domain + Data 계층 | ✅ 완료 (Calendar에 표시) |

---

## 완료된 개선 사항

| 항목 | 내용 |
|------|------|
| CalendarView 약 도트 버그 | `DayCell`에 `hasMedication: Bool` 추가로 수정 |
| MedicationFormViewController | `MedicationFormActions` 패턴 적용 (onCancel, onSaveCompleted) |
| MedicationFormSheet Coordinator | `UIViewControllerRepresentable.Coordinator` + `@Environment(\.dismiss)` 연결 |
| SceneDelegate | `.modelContainer` 중복 제거 |
| ExamListViewController | 구현 완성 확인 |
| UseCase Unit Tests | MedicationUseCase, HealthRecordUseCase, CycleRecordUseCase |

---

## 알려진 이슈

### 🟡 IDE 진단 경고 (CalendarView.swift)

- SourceKit 오류 다수 (`CalendarViewModel`, `AranFont`, `AranColor` 스코프 인식 실패)
- 빌드 및 테스트 자체는 정상 (`xcodebuild test` → TEST SUCCEEDED)
- 타겟 멤버십 또는 모듈 임포트 문제일 가능성 — Xcode에서 직접 확인 필요

---

## 브랜치 현황

| 브랜치 | 역할 | 상태 |
|--------|------|------|
| `feat/drugInjection` | 현재 작업 브랜치 | 진행 중 |
| `develop` | 통합 브랜치 | `dfdd6fc` 기준 |

---

## 다음 작업 순서 (MVP 2순위)

```
1. 감정 일기 — 이모지 선택 + 텍스트 입력, 날짜별 저장
2. 병원 일정 — 일정 추가/삭제
3. 알림 미리보기
4. 최근 검색어 (DrugInfo)
5. Health Record History View — 항목별 날짜순 히스토리
```

→ 자세한 목록은 `TODO.md` 참고

---

## 빌드 / 테스트

```bash
# 빌드
xcodebuild -scheme Aran

# 테스트
xcodebuild test -scheme Aran
```
