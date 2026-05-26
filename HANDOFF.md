# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `feat/drugInjection`
- **전체 진행도**: 캘린더/약주사/검사/약정보 탭 완료. 시술 기록 탭 Presentation 미구현.
- **다음 단계**: 캘린더 탭 나머지 입력 시트 + 시술 기록 탭 Presentation 계층

---

## 완료된 기능

| Feature | 스택 | 상태 |
|---------|------|------|
| Calendar | SwiftUI + Combine | ✅ 완료 |
| Medication / Injection | UIKit + RxSwift | ✅ 완료 |
| Health Record | UIKit + RxSwift | ✅ 완료 |
| Drug Information | SwiftUI + Combine | ✅ 완료 |
| CycleRecord / TransferRecord / PGTRecord | Domain + Data 계층 | ⚠️ Presentation 미구현 |

> ⚠️ **중요**: 시술 기록 탭은 Domain Entity, Repository, UseCase, SwiftData 모델까지는 구현되어 있으나 Presentation 계층(화면, ViewModel, DIContainer)은 미구현 상태입니다.

---

## 완료된 개선 사항

| 항목 | 내용 |
|------|------|
| CalendarView 약 도트 버그 | `DayCell`에 `hasMedication: Bool` 추가로 수정 |
| MedicationFormViewController | `MedicationFormActions` 패턴 적용 |
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

## 다음 작업

`TODO.md` 미완료 항목 참고. 우선순위 순서:

1. 캘린더 탭 — 감정 일기 / 병원 일정 / 생리 주기 입력 시트
2. 시술 기록 탭 — Presentation 계층 전체 (SwiftUI + Combine + Swift Charts)
3. 검사 탭 — Swift Charts Line Chart, 수치 히스토리 화면
4. 약/주사 탭 — 알림 미리보기
5. 약 정보 탭 — 최근 검색어
6. 테스트 — Repository / ViewModel / UI Test 전 레이어
7. 앱 완성도 — 다크모드, 앱 아이콘, 스플래시
8. 앱스토어 배포

---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16 Pro'
```
