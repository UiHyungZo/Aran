# Aran 약/주사 탭 — 작업 이어받기

## 현재까지 완료된 것

### 디자인 목업 반영
- `MedicationCell`: 약 종류 이모지 → 원형 상태 아이콘 (circle.fill/circle), disclosure indicator
- `MedicationFormViewController`: 성분명 필드 제거, 버튼 텍스트·삭제 버튼 스타일 변경
- `DrugSearchView`: 검색 결과 셀에서 효능 미리보기 제거 → 성분명·제조사 표시
- `NotificationSettingsViewController`: 신규 생성 (약별 토글 + 알림 미리보기 카드)
- `MedicationFlowCoordinator`: 알림 설정 화면 진입 추가 (벨 버튼)

### 6개 이슈 처리
- **Q3**: MedicationCell 도트 색상을 약 종류별로 분리 (경구=보라, 주사=초록, 패치=주황, 기타=회색)
- **Q4**: 캘린더 복용 체크 — `medicationLogs` in-place 업데이트로 즉시 반영
- **Q5**: 시간별 개별 복용 체크 — `MedicationLog.timeIndex: Int` 추가, 전 레이어 반영
- **Q6**: 알림 권한 거부 시 Alert → 설정으로 이동

### 정렬
- 캘린더 복용 약 목록: 시간 오름차순 정렬
- 약 수정 폼 복용 시간: 시간 오름차순 정렬

---

## 미결 사항 — 다음 작업

### 알림 설정 화면 — 시간별 행 표시 방식 결정 필요

**현재 상태**: 약 하나당 행 1개, 복용 시간이 여러 개여도 단일 토글

**논의 중**: 같은 약이라도 복용 시간별로 행을 분리해야 하는가?

예시:
```
고날에프 펜 · 오전 9:00   [토글]
고날에프 펜 · 오후 9:00   [토글]
```

**선택지**:
1. **약 단위 토글 유지** (구현 쉬움) — 시간별 행만 분리, 토글은 약 전체 on/off 공유
2. **시간별 개별 토글** (데이터 모델 변경 필요) — `Medication`에 `enabledTimeIndices: [Bool]` 추가 필요

**관련 파일**:
- `Aran/Presentation/Medication/NotificationSettingsViewController.swift` (NotificationToggleCell 수정)
- `Aran/Domain/Entities/Medication.swift` (옵션 2 선택 시 enabledTimeIndices 추가)
- `Aran/Data/Local/MedicationModel.swift` (옵션 2 선택 시)
- `Aran/Data/Notification/NotificationManager.swift` (옵션 2 선택 시 개별 시간 취소/예약)

---

## 주요 파일 경로

| 역할 | 경로 |
|------|------|
| 약 목록 화면 | `Aran/Presentation/Medication/MedicationListViewController.swift` |
| 약 등록/수정 폼 | `Aran/Presentation/Medication/MedicationFormViewController.swift` |
| 알림 설정 화면 | `Aran/Presentation/Medication/NotificationSettingsViewController.swift` |
| 약 검색 | `Aran/Presentation/Common/DrugSearch/DrugSearchView.swift` |
| 캘린더 뷰 | `Aran/Presentation/Calendar/CalendarView.swift` |
| 캘린더 ViewModel | `Aran/Presentation/Calendar/CalendarViewModel.swift` |
| MedicationLog 엔티티 | `Aran/Domain/Entities/MedicationLog.swift` |
| MedicationLog UseCase | `Aran/Domain/UseCases/MedicationLogUseCase.swift` |
| MedicationLog Repository | `Aran/Data/Repositories/MedicationLogRepository.swift` |
| Coordinator | `Aran/Application/MedicationFlowCoordinator.swift` |
| DI Container | `Aran/Application/DIContainer/MedicationSceneDIContainer.swift` |

---

## 빌드 명령

```bash
DEVELOPER_DIR=/Applications/Xcode-26.4.1.app/Contents/Developer \
  xcodebuild -scheme Aran \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```
