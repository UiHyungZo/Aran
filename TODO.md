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
- [x] 최근 검색어 — UserDefaults 저장/표시
- [x] 전체 화면 키보드 Dismiss UX 개선 — SwiftUI(`@FocusState` + `scrollDismissesKeyboard` + keyboard toolbar + `onTapGesture`), UIKit(`keyboardDismissMode` + tap gesture + `UITextFieldDelegate`) 8개 파일

---

## 미완료

### 테스트
- [ ] UseCase Test — TransferRecordUseCase
- [ ] Repository Test — CycleRecordRepository, TransferRecordRepository (Diary·HospitalVisit·MenstrualCycle은 해당 기능 구현 후)
- [ ] ViewModel Test — CalendarViewModel, DrugInfoViewModel, ExamHistoryViewModel, HealthRecordFormViewModel, HealthRecordViewModel, PGTFormViewModel
- [ ] UI Test — 캘린더 플로우, 약 등록 플로우, 약 검색 플로우, 채취/이식 입력 플로우, 검사 수치 입력 플로우

### 앱 완성도
- [ ] 다크모드 — 커스텀 컬러 Assets Light/Dark 두 벌 정의, Swift Charts 다크모드 색상
- [ ] 앱 아이콘 — 1024×1024 마스터 에셋, Xcode AppIcon 슬롯 전체
- [ ] 스플래시 — LaunchScreen.storyboard 앱 아이콘 중앙 배치

### 앱스토어 배포
- [ ] 개인정보처리방침 URL (GitHub Pages 또는 Notion)
- [ ] 앱 메타데이터 — 이름, 설명, 키워드, 카테고리 (의료/건강)
- [ ] 스크린샷 — iPhone 6.5인치 / 5.5인치, 주요 화면 5장
- [ ] TestFlight 내부 테스트 → 심사 제출
