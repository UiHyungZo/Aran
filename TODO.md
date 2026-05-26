# TODO

## MVP 1순위 (반드시 완료)

- [x] Calendar — 월간 달력, 날짜 선택, Bottom Sheet, 날짜별 상태 도트
- [x] Drug Search — 검색, 결과 목록, 상세 조회, Empty/Error 상태
- [x] Medication — 목록, 등록, 복용 체크, Swipe Action (중단/삭제)
- [x] Notification — 등록, 수정, 삭제, ON/OFF
- [x] Health Record — 수치 입력, 목록, 트렌드 표시 (↑↓)
- [x] UseCase Unit Test — MedicationUseCase, HealthRecordUseCase, CycleRecordUseCase

---

## 버그 / 구조 개선

- [x] CalendarView: 약/주사 저장 시 캘린더 도트 미표시 버그 수정 (`hasMedication` 파라미터 추가)
- [x] SceneDelegate.swift: `.modelContainer` 중복 제거 커밋
- [x] MedicationFormViewController: `dismissSelf()` → `MedicationFormActions` 패턴 교체
- [x] MedicationFormSheet: `UIViewControllerRepresentable.Coordinator` + `@Environment(\.dismiss)` 연결
- [x] ExamListViewController: 구현 상태 확인 및 완성

---

## 진행할 사항들

- [x] 캘린더 탭 - 기본 디폴트는 화면 페이지는 전체 캘린더 보여주기
- [x] 캘린더 탭 - 날짜를 클릭하게 된다면 클릭한 날짜의 주만 safeArea 밑에까지 그 주가 이동하면서 그 주만 보여주기 그리고 바텀은 그 주의 밑에까지 와야함
- [x] 감정 일기 — 이모지 선택 + 텍스트 입력, 날짜별 저장
- [ ] 병원 일정 — 일정 추가/삭제
- [ ] 알림 미리보기
- [ ] 최근 검색어 (DrugInfo)
- [ ] Health Record History View — 항목별 날짜순 히스토리

- [ ] Swift Charts — 수치 트렌드 그래프
- [ ] HealthKit 연동
- [ ] 배란일 자동 계산
- [ ] Widget / Siri Shortcut
- [ ] iPad Layout
- [ ] Full UI Test
- [ ] Firebase / Cloud Sync
