# TODO

## 완료

- [x] Calendar — 월간 달력, 날짜 선택, Bottom Sheet, 날짜별 상태 도트
- [x] Drug Search — 검색, 결과 목록, 상세 조회, Empty/Error 상태
- [x] Medication / Injection — 목록, 등록, 복용 체크, Swipe Action (중단/삭제)
- [x] Notification — 등록, 수정, 삭제, ON/OFF
- [x] Health Record — 수치 입력, 목록, 트렌드 표시 (↑↓)
- [x] UseCase Unit Test — MedicationUseCase, HealthRecordUseCase, CycleRecordUseCase, SearchDrugUseCase, MedicationNotificationUseCase
- [x] Repository Test — MedicationRepository, HealthRecordRepository, DrugRepository
- [x] Network Test — DrugAPIClient, DrugRouter
- [x] Mapper Test — MedicationMapper, DrugMapper
- [x] ViewModel Test — MedicationFormViewModel
- [x] CalendarView: 약/주사 저장 시 캘린더 도트 미표시 버그 수정
- [x] SceneDelegate: `.modelContainer` 중복 제거
- [x] MedicationFormViewController: `MedicationFormActions` 패턴 교체
- [x] MedicationFormSheet: Coordinator + `@Environment(\.dismiss)` 연결
- [x] ExamListViewController: 구현 완성
- [x] 감정 일기 입력 시트 — 이모지 선택 + 텍스트 입력 (최대 500자), SwiftData 저장
- [x] 병원 일정 입력 시트 — 일정 종류 (내원/채혈/초음파) + 메모, SwiftData 저장
- [x] 생리 주기 입력 시트 — 시작일 + cycleLength (기본 28일) → 배란 예정일 자동 계산

---

- [x] 시술 기록 탭 Presentation 전체 — 차수 목록, 채취/이식 입력, 이식 결과 기록, PGT/반착검사 화면
- [x] Swift Charts — 차수별 채취→수정→동결→이식 흐름 Bar Chart
- [x] 알림 미리보기 — 알림 내용 미리보기 + 개별 ON/OFF
- [x] Swift Charts — 항목별 수치 변화 Line Chart, 정상 범위 레퍼런스 라인
- [x] 수치 히스토리 화면 — 항목별 날짜순 목록
- [x] 최근 검색어 — SwiftData 기반 저장/표시
- [x] 전체 화면 키보드 Dismiss UX 개선 — SwiftUI(`@FocusState` + `scrollDismissesKeyboard` + keyboard toolbar + `onTapGesture`), UIKit(`keyboardDismissMode` + tap gesture + `UITextFieldDelegate`) 8개 파일

---

- [x] 즐겨찾기 — FavoriteDrug Domain/Data/Repository/UseCase + FavoriteDrugListView
- [x] 전문의약품 API — DrugApprovalAPIClient, DrugApprovalRouter, DrugApprovalDTO, DrugApprovalInfo (e약은요 fallback 포함)
- [x] 캘린더 검사 탭 detail — DateDetailSheet 내 HealthRecord 항목 상세 표시
- [x] 감정 일기 전체 sheet 완성 — CalendarView 내 DiaryEntry 전체 편집 UX

---

### 테스트
- [x] UseCase Test — TransferRecordUseCase
- [x] UseCase Test — FavoriteDrugUseCase, MedicationLogUseCase, MenstrualCycleUseCase, PGTRecordUseCase
- [x] Repository Test — CycleRecordRepository, TransferRecordRepository, FavoriteDrugRepository
- [x] Network Test — DrugApprovalRouter
- [x] Mapper Test — DrugApprovalMapper
- [x] ViewModel Test — CalendarViewModel, DrugInfoViewModel, ExamHistoryViewModel, HealthRecordFormViewModel, HealthRecordViewModel

---

### 테스트 (2차)
- [x] UseCase Test — DiaryEntryUseCase, HospitalVisitUseCase
- [x] ViewModel Test — MedicationViewModel, ProcedureRecordViewModel
- [x] UI Test — 탭 네비게이션 + 캘린더 / 약 검색 / 약·주사 / 검사 / 시술 기록 플로우 (`AranUITests/Flows/`)

### 앱 완성도
- [x] 다크모드 — 커스텀 컬러 Assets Light/Dark 정의
- [x] 앱 아이콘 — single-size 1024 universal (`AppIcon.appiconset`)
- [x] 스플래시 — LaunchScreen.storyboard + SplashContainerView

---

## 미완료

### 앱스토어 배포
- [ ] 개인정보처리방침 URL (GitHub Pages 또는 Notion)
- [ ] 앱 메타데이터 — 이름, 설명, 키워드, 카테고리 (의료/건강)
- [ ] 스크린샷 — iPhone 6.5인치 / 5.5인치, 주요 화면 5장 (README용 캡처 5장은 `screenshots/`에 있음, 앱스토어 규격 재촬영 필요)
- [ ] TestFlight 내부 테스트 → 심사 제출
