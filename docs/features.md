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

# MVP Structure

Aran MVP는 4개의 탭으로 구성한다.

| Tab                    | Stack             | Role         |
| ---------------------- | ----------------- | ------------ |
| Calendar               | SwiftUI + Combine | 날짜 기반 메인 허브  |
| Medication / Injection | UIKit + RxSwift   | 약/주사 및 알림 관리 |
| Health Record          | UIKit + RxSwift   | 검사 수치 기록     |
| Drug Information       | SwiftUI + Combine | 약 검색 및 상세 조회 |

---

# Tab 1 · Calendar

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

| Type  | Color  |
| ----- | ------ |
| 병원 일정 | Pink   |
| 약 알림  | Purple |
| 이식일   | Teal   |
| 배란일   | Amber  |

규칙:

* SwiftUI 상태 기반 UI 사용
* 날짜 계산 로직은 UseCase에서 수행
* View 내부 날짜 계산 금지

---

### Date Detail Bottom Sheet

날짜 선택 시 바텀시트 표시.

섹션:

* 채취 / 이식 기록
* 복용 약
* 감정 일기
* 검사 수치

예시 흐름:

```text
Calendar Date Tap
→ Bottom Sheet
→ Detail Sections
```

규칙:

* Empty 상태 제공
* 저장된 데이터 없을 경우 placeholder 표시
* 날짜별 모든 기록을 허브처럼 연결

---

### Retrieval / Transfer Record

기능:

* 채취 개수 입력
* 수정 개수 입력
* 동결 개수 입력
* 배아 등급 입력
* 이식 개수 입력
* 신선/동결 여부 입력

예시:

```text
2차 시술
채취 12개
수정 9개
동결 6개
3AA 배아 1개 이식
```

규칙:

* CycleRecord 기준 관리
* 날짜 기반 Calendar 연결
* 복잡한 계산은 UseCase에서 수행

---

### Emotional Diary

기능:

* 감정 이모지 선택
* 텍스트 기록
* 날짜별 감정 기록 저장

예시:

```text
😢
긴장되지만 기대돼요
```

규칙:

* 감정 기록은 보조 기능
* 캘린더 흐름을 방해하지 않는다
* Empty 상태를 우선 지원

---

### Hospital Schedule

기능:

* 병원 일정 추가
* 병원 일정 삭제

예시:

```text
난임센터 방문
초음파 검사
피검사
```

우선순위:

* MVP 2순위

규칙:

* 단순 일정 관리 수준 유지
* 범용 캘린더 앱처럼 확장하지 않는다

---

## Calendar Non-goals

MVP 제외:

* 생리 주기 입력
* 배란일 자동 계산
* 복잡한 cycle prediction
* Apple Calendar sync

---

# Tab 2 · Medication / Injection

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

* 약 목록 표시
* 복용 여부 체크
* 활성/비활성 상태 구분
* 복용 시간 표시

표시 정보:

* 약 이름
* 용량
* 타입
* 복용 시간
* 체크 상태

규칙:

* UITableView 기반
* Driver 기반 UI 바인딩 우선
* 상태는 RxSwift로 관리

---

### Medication Check

기능:

* 복용 완료 체크
* 실시간 상태 변경

예시:

```text
☑ 프로게스테론
☐ 에스트라디올
```

규칙:

* 사용자 입력은 PublishRelay 사용
* 현재 상태는 BehaviorRelay 사용
* ViewController 내부 비즈니스 로직 금지

---

### Swipe Actions

왼쪽 스와이프 기능 제공.

동작:

* 중단
* 삭제

차이점:

| Action | Behavior      |
| ------ | ------------- |
| 중단     | 기록 유지 + 알림 중단 |
| 삭제     | 데이터 제거        |

규칙:

* 비활성화 상태는 history 유지
* swipe action은 UIKit native 방식 사용

---

### Medication Registration

기능:

* 약 추가
* DrugSearchView register mode 사용
* 자동 입력 지원

자동 입력:

* 약 이름
* 성분명

사용자 입력:

* 용량
* 복용 시간
* 메모
* 알림 여부

흐름:

```text
Medication Tab
→ Add Button
→ DrugSearchView(register)
→ Select Drug
→ MedicationForm
```

---

### Notifications

기능:

* 복용 시간별 알림 등록
* 알림 수정
* 알림 삭제
* 알림 ON/OFF

규칙:

* UserNotifications 사용
* notificationId를 schedule 단위로 관리
* 알림 수정 시 기존 알림 취소 후 재등록

예시:

```text
프로게스테론 복용 시간이에요
```

---

## Medication Non-goals

MVP 제외:

* Apple Watch 연동
* HealthKit 연동
* 복용 통계 분석
* Siri Shortcut

---

# Tab 3 · Health Record

## Stack

* UIKit
* RxSwift

## Role

시험관 시술 관련 검사 수치 기록.

---

## Main Features

### Health Record Input

기능:

* 검사 항목 선택
* 수치 입력
* 날짜 선택
* 메모 입력

지원 항목:

* FSH
* AMH
* AFC
* E2
* Progesterone

규칙:

* 숫자 입력 validation 제공
* 잘못된 값 입력 시 저장 버튼 비활성
* validation은 ViewModel에서 처리

---

### Health Record List

기능:

* 최신 수치 표시
* 이전 대비 증감 표시
* 날짜 표시

예시:

```text
FSH 8.2
↓ 1.4
```

규칙:

* UITableView 기반
* TrendBadge 제공
* 최신값 기준 정렬

---

### History View

기능:

* 항목별 히스토리 조회
* 날짜순 목록 표시

예시:

```text
2024.03.12 - 8.2
2024.02.05 - 9.6
```

우선순위:

* MVP 2순위

---

### PGT / Genetic Record

Phase 2 기능.

예정 기능:

* PGT 결과
* 염색체 검사
* 모자이크 결과

MVP에서는 제외한다.

---

## Health Record Non-goals

MVP 제외:

* Swift Charts
* 자동 해석 기능
* 의료 진단 기능
* 그래프 분석

---

# Tab 4 · Drug Information

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
* debounce 검색
* 실시간 결과 표시

규칙:

* Combine debounce 사용
* 기본 debounce 시간: 0.3초
* 빈 검색어 API 호출 금지

예시:

```swift
.debounce(for: .milliseconds(300))
```

---

### Search Result List

표시 정보:

* 약 이름
* 제약사
* 성분 요약

기능:

* 상세 화면 이동
* register mode에서 약 선택 가능

규칙:

* Loading 상태 제공
* Empty 상태 제공
* Error 상태 제공

---

### Drug Detail

표시 정보:

* 효능
* 용법
* 경고
* 주의사항
* 상호작용
* 부작용
* 보관법

규칙:

* NavigationStack 기반
* 긴 텍스트 스크롤 지원
* Warning Banner 제공

---

### Add Medication Flow

약 상세 화면에서 약 등록 가능.

흐름:

```text
Drug Detail
→ Add Medication
→ MedicationFormViewController
```

브리징:

```text
SwiftUI
→ UIHostingController
→ UIKit
```

규칙:

* register mode와 흐름 공유
* 선택된 약 정보 자동 입력

---

### Fallback Policy

검색 결과 없음은 정상 UX Case다.

예시:

```text
찾는 약이 없나요?
직접 입력하기
```

네트워크 오류:

```text
Retry
→ 실패 시 fallback 안내
```

규칙:

* Empty Result를 fatal error로 처리하지 않는다
* IVF 약 특성상 직접 입력 fallback 제공

---

## Drug Information Non-goals

MVP 제외:

* 즐겨찾기
* OCR 약 검색
* 이미지 검색
* 오프라인 캐시 검색

---

# DrugSearch Reuse Policy

DrugSearchView는 재사용 컴포넌트다.

## browse mode

사용 위치:

* Drug Information Tab

동작:

```text
검색
→ 상세 조회
```

---

## register mode

사용 위치:

* Medication Registration

동작:

```text
검색
→ 선택
→ MedicationForm 자동 입력
```

규칙:

* 검색 로직은 공유
* mode에 따라 선택 후 흐름만 변경

---

# MVP Priority Policy

## 1순위

반드시 구현:

* Calendar
* Date Bottom Sheet
* Medication List
* Medication Registration
* Notification Flow
* Drug Search
* Health Record Input
* UseCase Unit Test

---

## 2순위

시간 되면 추가:

* 감정 일기 입력 화면
* 병원 일정
* 알림 미리보기
* 최근 검색어
* History View

---

## Phase 2

MVP 제외:

* 생리 주기 계산
* 배란일 자동 계산
* Swift Charts
* HealthKit
* 전체 UI Test
* Firebase
* iPad 대응

---

# UX Principles

## 핵심 원칙

* 치료 흐름 방해 최소화
* 입력 단계 단순화
* Empty 상태 친절하게 제공
* 직접 입력 fallback 제공
* 사용자가 “잊지 않게” 돕는 UX

---

## Empty State

예시:

```text
기록된 수치가 없어요
```

```text
직접 입력하기
```

규칙:

* Empty 상태를 오류처럼 표현하지 않는다
* 사용자가 다음 행동을 이해할 수 있어야 한다

---

# Portfolio Principles

이 앱은 포트폴리오 프로젝트이다.

중요 목표:

* 기술 선택 이유 설명 가능
* Clean Architecture 설명 가능
* UIKit + SwiftUI 혼합 이유 설명 가능
* RxSwift + Combine 경계 설명 가능
* 테스트 가능한 구조 증명 가능

우선순위:

1. 명확한 구조
2. 설명 가능한 코드
3. 테스트 가능성
4. 유지보수성
5. UI polish
