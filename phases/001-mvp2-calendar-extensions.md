# Phase 001: MVP 2순위 — Calendar 2단계 시트 확장

## 목표
- 감정 일기, 병원 일정, 생리 주기 기능을 CalendarView의 2단계 바텀시트로 구현한다.

## 참조 문서
- `CLAUDE.md`
- `docs/features.md`
- `docs/data-model.md`
- `docs/architecture.md`
- `docs/UI_GUIDE.md`

## 작업 범위

### 감정 일기
- `DiaryEntry` SwiftData 모델 추가 (`id, date, emotion, content`)
- `DiaryRepository` + Protocol + Mock
- `DiaryUseCase` (저장 / 날짜별 조회)
- CalendarView 2단계 시트 — 이모지 선택(😊😢😰😤🥰) + 텍스트 입력(최대 500자)
- 1단계 시트 감정 일기 섹션 — 이모지 + 텍스트 미리보기

### 병원 일정
- `HospitalVisit` SwiftData 모델 추가 (`id, visitDate, visitType, memo`)
- `HospitalVisitRepository` + Protocol + Mock
- `HospitalVisitUseCase` (저장 / 수정 / 삭제 / 날짜 범위 조회)
- CalendarView 2단계 시트 — 일정 종류(내원/채혈/초음파) chip 선택 + 메모
- 1단계 시트 병원 일정 섹션 — 일정 종류 + 메모 표시

### 생리 주기
- `MenstrualCycle` SwiftData 모델 추가 (`id, startDate, cycleLength`)
- `MenstrualCycleRepository` + Protocol + Mock
- `MenstrualCycleUseCase` (시작일 저장 / 배란 예정일 자동 계산 / 주기 수정)
- CalendarView 2단계 시트 — 시작일(자동 입력) + cycleLength 스테퍼(기본 28) + 배란 예정일 자동 표시
- 캘린더 도트 — 앰버(배란 예정일), 핑크 사각(생리 기간)

## 제외 범위
- HealthKit 연동
- 생리 주기 예측 알고리즘 (단순 startDate + cycleLength/2 계산만)

## 변경 예정 파일
- `Aran/Domain/Entities/DiaryEntry.swift` (신규)
- `Aran/Domain/Entities/HospitalVisit.swift` (신규)
- `Aran/Domain/Entities/MenstrualCycle.swift` (신규)
- `Aran/Domain/Repositories/DiaryRepositoryProtocol.swift` (신규)
- `Aran/Domain/Repositories/HospitalVisitRepositoryProtocol.swift` (신규)
- `Aran/Domain/Repositories/MenstrualCycleRepositoryProtocol.swift` (신규)
- `Aran/Domain/UseCases/DiaryUseCase.swift` (신규)
- `Aran/Domain/UseCases/HospitalVisitUseCase.swift` (신규)
- `Aran/Domain/UseCases/MenstrualCycleUseCase.swift` (신규)
- `Aran/Data/Local/DiaryEntryModel.swift` (신규)
- `Aran/Data/Local/HospitalVisitModel.swift` (신규)
- `Aran/Data/Local/MenstrualCycleModel.swift` (신규)
- `Aran/Data/Repositories/DiaryRepository.swift` (신규)
- `Aran/Data/Repositories/HospitalVisitRepository.swift` (신규)
- `Aran/Data/Repositories/MenstrualCycleRepository.swift` (신규)
- `Aran/Presentation/Calendar/CalendarViewModel.swift` (수정)
- `Aran/Presentation/Calendar/DateDetailSheet.swift` (수정)
- `AranTests/Mocks/MockDiaryRepository.swift` (신규)
- `AranTests/Mocks/MockHospitalVisitRepository.swift` (신규)
- `AranTests/Mocks/MockMenstrualCycleRepository.swift` (신규)
- `AranTests/UseCases/DiaryUseCaseTests.swift` (신규)
- `AranTests/UseCases/HospitalVisitUseCaseTests.swift` (신규)
- `AranTests/UseCases/MenstrualCycleUseCaseTests.swift` (신규)

## 완료 조건
- [ ] 감정 일기: 날짜별 저장/조회/수정 동작
- [ ] 병원 일정: 저장/수정/삭제 동작, 캘린더 핑크 도트 표시
- [ ] 생리 주기: 시작일 저장, 배란 예정일 자동 계산 정확
- [ ] 3개 UseCase Unit Test 통과
- [ ] 1단계 시트에 각 섹션 반영 확인

## 상태
pending
