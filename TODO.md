# TODO

## MVP 1순위 (반드시 완료)

- [x] Calendar — 월간 달력, 날짜 선택, Bottom Sheet, 날짜별 상태 도트
- [x] Drug Search — 검색, 결과 목록, 상세 조회, Empty/Error 상태
- [x] Medication — 목록, 등록, 복용 체크, Swipe Action (중단/삭제)
- [x] Notification — 등록, 수정, 삭제, ON/OFF
- [x] Health Record — 수치 입력, 목록, 트렌드 표시 (↑↓)
- [ ] UseCase Unit Test — MedicationUseCase, HealthRecordUseCase, CycleRecordUseCase

---

## 버그 / 구조 개선

- [ ] SceneDelegate.swift: `.modelContainer` 중복 제거 커밋
- [ ] MedicationFormViewController: `dismissSelf()` → `MedicationFormActions` 패턴 교체
- [ ] MedicationFormSheet: `UIViewControllerRepresentable.Coordinator` + `@Environment(\.dismiss)` 연결
- [ ] ExamListViewController: 구현 상태 확인 및 완성

---

## MVP 2순위 (시간 되면)

- [ ] 감정 일기 — 이모지 선택 + 텍스트 입력, 날짜별 저장
- [ ] 병원 일정 — 일정 추가/삭제
- [ ] 알림 미리보기
- [ ] 최근 검색어 (DrugInfo)
- [ ] Health Record History View — 항목별 날짜순 히스토리

---

## Phase 2 (MVP 이후)

- [ ] Swift Charts — 수치 트렌드 그래프
- [ ] HealthKit 연동
- [ ] 배란일 자동 계산
- [ ] Widget / Siri Shortcut
- [ ] iPad Layout
- [ ] Full UI Test
- [ ] Firebase / Cloud Sync
