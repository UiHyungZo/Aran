# Roadmap

## Goal

Aran은 IVF 치료 관리 흐름에 집중한 iOS 포트폴리오 앱이다.

로드맵 목표:

* 제한된 기간 안에 MVP 완성
* 핵심 사용자 흐름 우선 구현
* 과도한 기능 확장 방지
* 면접에서 설명 가능한 수준까지 완성
* 점진적으로 확장 가능한 구조 유지

이 프로젝트는 “많은 기능”보다 “완성도 있는 핵심 흐름”을 우선한다.

---

# Development Strategy

전체 전략:

```text id="x4j6z1"
MVP First
→ Stable Core Flow
→ UI Polish
→ Phase 2 Expansion
```

우선순위:

1. 핵심 기능 완성
2. 구조 안정화
3. 테스트 가능성
4. UI polish
5. 추가 기능

---

# MVP Scope

MVP 목표:

* IVF 치료 흐름 기록 가능
* 약 등록 및 알림 가능
* 검사 수치 기록 가능
* 약 검색 가능
* Calendar 기반 흐름 연결 가능

---

# MVP Timeline

예상 기간:

```text id="n9w14w"
약 4주
```

---

# Week 1 · Foundation

## Goal

프로젝트 기본 구조와 핵심 아키텍처 구성.

---

## Tasks

### Project Setup

구현:

* Xcode Project 생성
* SPM 설정
* 폴더 구조 생성
* Target 구성
* Build Setting 정리

---

### Architecture Setup

구현:

* Clean Architecture 구조 생성
* Layer 분리
* Dependency 방향 구성
* DIContainer 생성
* Coordinator 흐름 구성

---

### Infrastructure Setup

구현:

* Alamofire 설정
* SwiftData Stack 설정
* Notification Manager 생성
* APIClient 생성
* Router 구조 생성

---

### Base Components

구현:

* DesignSystem
* Common Error
* Base UI Component
* Formatter
* Extension

---

## Deliverables

완료 기준:

* 앱 실행 가능
* 기본 Tab 구조 동작
* API 호출 가능
* SwiftData 저장 가능
* Notification 등록 가능

---

# Week 2 · Core Features

## Goal

핵심 사용자 흐름 구현.

---

## Calendar

구현:

* Monthly Calendar
* Date Selection
* Bottom Sheet
* 날짜별 상태 표시

우선순위:

```text id="z2mn7k"
Highest
```

---

## Drug Search

구현:

* DrugSearchView
* Search debounce
* Search Result List
* Drug Detail View
* Empty State
* Error State

흐름:

```text id="k2d07w"
Search
→ Result
→ Detail
```

---

## Medication Registration

구현:

* Add Medication
* DrugSearch register mode
* Medication Form
* 직접 입력 fallback

흐름:

```text id="6g5zcm"
Medication
→ DrugSearch
→ Form
→ Save
```

---

## Deliverables

완료 기준:

* 약 검색 가능
* 약 등록 가능
* Calendar 진입 가능
* Bottom Sheet 표시 가능

---

# Week 3 · Medication / Health Flow

## Goal

실제 IVF 관리 핵심 흐름 완성.

---

## Medication

구현:

* Medication List
* 복용 체크
* Swipe Action
* 활성/비활성 상태
* Schedule 저장

---

## Notification

구현:

* 알림 등록
* 알림 수정
* 알림 삭제
* Schedule별 notificationId 관리

---

## Health Record

구현:

* 검사 수치 입력
* 기록 저장
* 최신값 표시
* 날짜별 기록 조회

---

## Retrieval / Transfer Record

구현:

* 채취 기록
* 수정 기록
* 동결 기록
* 이식 기록

---

## Deliverables

완료 기준:

* Medication flow 완성
* Notification 동작
* HealthRecord 저장 가능
* IVF cycle 기록 가능

---

# Week 4 · Stabilization

## Goal

MVP 안정화 및 포트폴리오 품질 개선.

---

## Testing

구현:

* UseCase Test
* ViewModel Test
* Mock Repository
* 핵심 Flow Test

우선순위:

```text id="f4g20x"
UseCase 중심
```

---

## UI Polish

구현:

* Empty State 개선
* Loading 상태 개선
* Error UX 개선
* Spacing / Typography 조정

---

## Documentation

구현:

* README 작성
* GIF 제작
* Architecture 설명 정리
* 기술 선택 이유 정리

---

## Refactoring

구현:

* Naming 정리
* 파일 구조 정리
* 불필요한 abstraction 제거
* TODO 정리

---

## Deliverables

완료 기준:

* 핵심 flow bug-free
* README 완성
* 테스트 작성
* GitHub 업로드 가능 상태

---

# MVP Release Criteria

다음 조건 충족 시 MVP 완료로 간주한다.

---

## Required

필수:

* Calendar 동작
* Medication 등록 가능
* Notification 동작
* HealthRecord 저장 가능
* Drug Search 동작
* SwiftData persistence 정상 동작
* UseCase 테스트 존재

---

## Optional

가능하면 포함:

* 감정 일기
* 병원 일정
* 최근 검색어
* UI Test 일부

---

# Non-goals

MVP에서 하지 않는 것:

* Firebase
* Cloud Sync
* HealthKit
* Apple Watch
* iPad 대응
* OCR 약 검색
* 복잡한 통계 기능

---

# Phase 2

MVP 이후 검토 가능 기능. (일부는 이미 구현 완료되어 분리 표기)

---

## ✅ 구현 완료 (MVP 범위 외였으나 선반영됨)

* Swift Charts (검사 수치 / 시술 기록 차트)
* Trend Graph
* PGT 기록
* 배란일 계산
* 생리 주기 추적
* 최근 검색어
* 다크모드
* 기본 UI Test (주요 사용자 플로우)

---

## Health Features

후보(미구현):

* HealthKit 연동
* Medication Statistics

---

## IVF Features

후보(미구현):

* 난자/배아 통계

---

## UX Features

후보(미구현):

* 검색 캐시
* Widget
* Siri Shortcut

---

## Technical Features

후보(미구현):

* Cloud Sync
* iPad Layout
* Snapshot Test
* Full UI Test
* Analytics

---

# Scope Control Policy

MVP 기간 동안:

금지:

* 새로운 대규모 feature 추가
* 구조 전체 리팩토링
* reactive stack 변경
* persistence 교체
* 아키텍처 전면 수정

허용:

* bug fix
* naming 개선
* 작은 구조 개선
* UX polish

---

# Risk Management

## Risk 1 · Feature Overgrowth

위험:

* 기능이 계속 늘어남

대응:

* IVF 핵심 흐름 우선
* Non-goal 유지
* MVP 기준 유지

---

## Risk 2 · Architecture Overengineering

위험:

* abstraction 과다
* protocol 과다

대응:

* 사용 사례 1개 abstraction 지양
* readability 우선
* explicit naming 유지

---

## Risk 3 · Reactive Complexity

위험:

* RxSwift + Combine 혼합 복잡도 증가

대응:

* Feature 단위 stack 고정
* 브리징 최소화
* reactive boundary 유지

---

## Risk 4 · Notification Complexity

위험:

* notificationId 정합성 문제

대응:

* schedule 단위 관리
* 수정 시 기존 알림 제거 후 재등록
* repository 레벨 검증

---

# Success Criteria

이 프로젝트의 성공 기준:

* IVF 흐름이 자연스럽게 연결된다.
* 구조를 면접에서 설명 가능하다.
* 기술 선택 이유를 설명 가능하다.
* 테스트 가능한 구조를 보여준다.
* README와 GIF만으로 프로젝트 이해가 가능하다.

---

# Portfolio Strategy

이 프로젝트는 “실제 서비스 수준 완성”보다 다음을 우선한다.

우선순위:

1. 설명 가능한 구조
2. 명확한 책임 분리
3. 테스트 가능성
4. 현실적인 MVP 범위
5. 유지보수성
6. UI polish

---

# Final Deliverables

최종 제출물:

* GitHub Repository
* README
* Architecture Docs
* GIF Demo
* 테스트 코드
* Clean Commit History

---

# README Checklist

README 포함 내용:

* 프로젝트 소개
* 기술 스택
* Architecture 설명
* Folder Structure
* 핵심 기능
* GIF
* 기술 선택 이유
* 테스트 전략
* Trouble Shooting
* Future Improvements

---

# GitHub Checklist

업로드 전 체크:

* API Key 제거
* Debug print 제거
* TODO 정리
* 불필요한 파일 제거
* README 최신화
* Build 확인
* Test 확인

---

# Portfolio Principles

이 로드맵은 “완벽한 앱”보다 “완성도 있는 포트폴리오”를 만드는 데 목적이 있다.

핵심:

* 작은 범위를 끝까지 완성한다.
* 기술 선택 이유를 설명 가능하게 만든다.
* 과도한 기능보다 안정적인 흐름을 우선한다.
* MVP 범위를 끝까지 유지한다.
