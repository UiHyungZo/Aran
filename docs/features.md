# Features

## Product Scope

Aran은 시험관 시술(IVF) 관리에 특화된 iOS 앱이다.

범용 건강관리 앱이 아니라 IVF 치료 흐름 관리에 집중한다.

핵심 목표:

* 치료 일정 관리
* 약물/주사 추적
* 검사 수치 기록
* 차수별 채취/이식 기록
* IVF 치료 흐름 시각화
* 감정 기록 보조

우선순위:

1. 치료 일정
2. 약물 관리
3. 검사 기록
4. IVF Cycle 흐름 기록
5. 감정 기록

범용 운동/식단/헬스케어 기능은 우선순위가 낮다.

---

# App Structure — 5탭

| Tab | Stack | Role |
|-----|-------|------|
| 📅 캘린더 | SwiftUI + Combine | 날짜 기반 메인 허브 |
| 💊 약/주사 | UIKit + RxSwift | 약/주사 및 알림 관리 |
| 🏥 검사 | UIKit + RxSwift + Swift Charts | 검사 수치 기록 |
| 🗂 시술 기록 | SwiftUI + Combine + Swift Charts | 차수별 IVF 기록 |
| 🔍 약 정보 | SwiftUI + Combine | 약 검색 및 상세 조회 |

---

# Tab 1 · 📅 캘린더

## Stack

* SwiftUI
* Combine

## Role

앱의 메인 허브.

모든 치료 기록은 날짜 중심으로 연결된다.

---

## Main Features

### Monthly Calendar

기능:

* 월간 달력 표시
* 날짜별 상태 도트 표시
* 날짜 선택
* 월 이동

도트 종류:

| Type | Color |
|------|-------|
| 병원 일정 | Pink (채워진 원) |
| 약 복용 알림 | Purple (채워진 원) |
| 이식일 | Green (채워진 원) |
| 배란일 | Amber (채워진 원) |
| 생리 기간 | Pink (사각 도트) |

규칙:

* SwiftUI 상태 기반 UI 사용
* 날짜 계산 로직은 UseCase에서 수행
* View 내부 날짜 계산 금지

---

### 2단계 바텀시트 구조

날짜 선택 시 1단계 시트, 섹션 탭 시 2단계 시트로 진입.

```text
캘린더 날짜 탭
→ 1단계 시트 (날짜 요약)
→ 섹션 탭
→ 2단계 시트 (항목별 입력/수정)
```

규칙:

* 2단계 진입 시 1단계 시트는 25% opacity로 뒤에 유지
* 각 섹션은 기록 있을 때 / 없을 때 상태 구분
* 수정/삭제는 2단계 시트에서만 가능

---

### 1단계 시트 섹션

| 섹션 | 기록 있을 때 | 기록 없을 때 | 탭 동작 |
|------|-------------|-------------|--------|
| 병원 일정 | 일정 종류(복수) + 메모 | "일정 없음" | 2단계: 병원 일정 입력/수정 |
| 복용 약 | 약 이름 pill + 체크박스 | "복용 약 없음" | 체크 토글. 약 추가는 약/주사 탭 |
| 감정 일기 | 이모지 + 텍스트 미리보기 | "기록 없음" | 2단계: 감정 일기 입력/수정 |
| 검사 수치 | 항목·수치 요약 | "기록 없음" | 2단계: 검사 수치 입력/수정 |
| 생리 시작일 | 생리 시작일로 표시 | "오늘로 기록하기" 버튼 | 2단계: 생리 주기 입력/수정 |

---

### 복용 약 체크 (MedicationLog)

기능:

* 1단계 시트에서 각 약 옆 체크박스로 당일 복용 완료 토글
* 체크 상태는 날짜별로 저장 (MedicationLog)
* 약 추가/수정/삭제는 약/주사 탭에서만 가능

규칙:

* MedicationLog 저장: `(medicationId, logDate, isTaken)`
* 날짜별 복용 상태 독립 관리

---

### 병원 일정 입력/수정 (2단계)

기능:

* 일정 종류 복수 선택 (내원 / 채혈 / 초음파)
* 메모 입력
* 수정 가능 · 삭제 가능

규칙:

* visitTypes: [String] 으로 복수 저장
* 같은 날 여러 종류 동시 선택 지원

---

### 감정 일기 입력/수정 (2단계)

기능:

* 감정 이모지 선택
* 텍스트 기록 (최대 500자)
* 날짜별 감정 기록 저장
* 수정 가능 · 삭제 가능

---

### 생리 주기 입력/수정 (2단계)

기능:

* 생리 시작일 기록 (자동)
* 주기 길이 설정 (기본 28일)
* 배란 예정일 자동 계산
* 수정 가능

---

### 검사 수치 입력/수정 (2단계)

기능:

* 항목 선택 · 수치 · 단위 · 측정일 · 메모
* 수정 가능 · 삭제 가능
* 검사 탭과 데이터 연동

---

## Calendar Non-goals

MVP 제외:

* Apple Calendar sync
* 복잡한 cycle prediction
* HealthKit 연동

---

# Tab 2 · 💊 약/주사

## Stack

* UIKit
* RxSwift
* RxCocoa

## Role

복용 약 및 주사 관리.

복용 시간과 알림 흐름을 중심으로 구성한다.

---

## Main Features

### Medication List

기능:

* 약 목록 표시 (UITableView)
* 복용 여부 체크
* 활성/비활성 상태 구분
* 복용 시간 표시

규칙:

* Driver 기반 UI 바인딩 우선
* 상태는 BehaviorRelay로 관리

---

### 약 셀 탭 → 수정 화면

기능:

* 약 이름·성분·용량·복용 시간·알림 설정 수정 가능

규칙:

* MedicationFormViewController 재사용
* 수정 모드 초기값 자동 바인딩

---

### Swipe Actions

왼쪽 스와이프 기능:

| Action | Behavior |
|--------|----------|
| 중단 | 기록 유지 + 알림 중단 |
| 삭제 | 데이터 제거 |

---

### Medication Registration

흐름:

```text
약/주사 탭
→ + 버튼
→ DrugSearchView (register 모드)
→ 약 선택
→ MedicationFormVC
```

---

### Notifications

기능:

* 복용 시간별 알림 등록/수정/삭제/ON·OFF
* 알림 미리보기 + 개별 ON/OFF

규칙:

* notificationId를 schedule 단위로 관리
* 수정 시 기존 알림 취소 후 재등록

---

## Medication Non-goals

MVP 제외:

* Apple Watch 연동
* HealthKit 연동
* 복용 통계 분석
* Siri Shortcut

---

# Tab 3 · 🏥 검사

## Stack

* UIKit
* RxSwift
* Swift Charts

## Role

혈액/초음파 수치 전용 탭. PGT/염색체는 시술 기록 탭에서 관리.

---

## Main Features

### 검사 항목

기본 제공 7개:

| 항목 | 단위 | 카테고리 |
|------|------|---------|
| FSH | mIU/mL | 난소 기능 |
| AMH | ng/mL | 난소 기능 |
| AFC | 개 | 난소 기능 |
| E2 | pg/mL | 호르몬 |
| P4 | ng/mL | 호르몬 |
| LH | mIU/mL | 호르몬 |
| β-hCG | mIU/mL | 임신 확인 |

직접 추가: 이름·단위 입력 → HealthRecord.type(String)으로 저장

---

### Health Record Input

기능:

* 검사 항목 선택 (기본 7개 + 커스텀)
* 수치/단위 입력
* 날짜 선택
* 메모 입력
* 수정 가능 · 삭제 가능

규칙:

* 숫자 validation은 ViewModel에서 처리
* 저장 버튼 활성화 조건: 항목 선택 + 유효한 수치

---

### Health Record List

기능:

* 섹션별(난소기능/호르몬 등) 그룹화
* 항목별 최신 수치 + 증감 TrendBadge
* 날짜 표시

규칙:

* UITableView 기반
* TrendBadge: 최신값 - 이전값 기준 ↑↓ 표시

---

### History View

기능:

* 항목별 시간순 목록 조회

---

### Swift Charts — Trend

기능:

* 항목별 수치 변화 Line Chart
* 정상 범위 레퍼런스 라인

---

## Health Record Non-goals

MVP 제외:

* 자동 해석 기능
* 의료 진단 기능

---

# Tab 4 · 🗂 시술 기록

## Stack

* SwiftUI
* Combine
* Swift Charts

## Role

차수별 IVF 기록 전용 탭.

---

## Main Features

### 차수 목록

기능:

* 차수별 카드 — 채취·수정·동결 개수, 이식 결과 요약
* 진행중 / 성공 / 실패 배지
* 차수 카드 탭 → 상세 화면

---

### 차수 상세 화면

기능:

* 해당 차수 전체 이력 한눈에 표시
* 채취 → 수정 → 동결 → 이식 → PGT 결과 흐름

---

### 채취/이식 입력

기능:

* 차수 선택
* 개수·등급·동결/신선 입력
* SwiftData 저장

---

### 이식 결과 입력

기능:

* 이식일 · 등급 · 개수 · 결과(성공/실패/진행중)
* 나중에 별도 업데이트 가능

---

### PGT / 염색체 / 반착검사 기록

기능:

* PGT-A/M 결과
* 부부 염색체 검사
* 반착검사 결과
* 차수에 연결

---

### Swift Charts — 차수별 비교

기능:

* 차수별 채취→수정→동결→이식 흐름 Bar Chart
* 전체 차수 비교

---

# Tab 5 · 🔍 약 정보

## Stack

* SwiftUI
* Combine

## Role

e약은요 API 기반 약 검색 기능.

---

## Main Features

### Drug Search

기능:

* 약 이름 검색
* Combine debounce (0.3초)
* 실시간 결과 표시

규칙:

* 빈 검색어 API 호출 금지
* 최소 2자 입력 안내

---

### Search Result List

표시: 약명·성분 요약

상태: Loading / Empty / Error

---

### Drug Detail

표시: 효능·용법·경고·주의사항·상호작용·부작용·보관법

기능: 전문의약품 경고 배너

---

### Add Medication Flow

```text
Drug Detail
→ "이 약 추가하기"
→ MedicationFormViewController
```

---

### 최근 검색어

* SwiftData 기반 저장/표시
* ViewModel은 UseCase를 통해 저장/조회

---

### Fallback Policy

| 상황 | 처리 |
|------|------|
| 검색 결과 없음 | "직접 입력하기" → 빈 MedicationFormVC |
| 네트워크 오류 | retry 1회 → 오류 토스트 → 직접 입력 폴백 |
| 빈 검색어 | API 호출 차단, 최소 2자 입력 안내 |

---

# DrugSearch Reuse Policy

DrugSearchView는 재사용 컴포넌트다.

## browse mode

사용 위치: 약 정보 탭
동작: 검색 → 상세 조회

## register mode

사용 위치: 약/주사 탭 등록
동작: 검색 → 선택 → MedicationForm 자동 입력

---

# MVP Priority Policy

## 1순위 (반드시 구현)

* Calendar 2단계 바텀시트 전체
* 복용 약 체크 (MedicationLog)
* 병원 일정 복수 종류 선택
* Medication List / Registration / Notification
* Drug Search (browse + register)
* Health Record Input / List / TrendBadge
* CycleRecord Presentation 전체
* UseCase Unit Test

## 2순위 (시간 되면 추가)

* 알림 미리보기
* 최근 검색어
* Swift Charts (검사 탭 + 시술 기록 탭)
* 수치 히스토리 화면

## Phase 2

* HealthKit
* 전체 UI Test
* Firebase
* iPad 대응

---

# UX Principles

* 치료 흐름 방해 최소화
* 입력 단계 단순화
* Empty 상태 친절하게 제공
* 직접 입력 fallback 제공
* 수정/삭제 흐름을 명확하게

---

# Portfolio Principles

중요 목표:

* 기술 선택 이유 설명 가능
* Clean Architecture 설명 가능
* UIKit + SwiftUI 혼합 이유 설명 가능
* RxSwift + Combine 경계 설명 가능
* 테스트 가능한 구조 증명 가능
