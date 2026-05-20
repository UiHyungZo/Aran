# Git Convention

## Goal

Aran의 Git 규칙은 포트폴리오 프로젝트의 작업 흐름을 명확하게 보여주기 위한 기준이다.

목표:

* 커밋 히스토리만 봐도 개발 흐름을 이해할 수 있게 한다.
* 하나의 커밋은 하나의 목적만 가지게 한다.
* 기능 구현, 리팩토링, 테스트, 문서 작업을 명확히 구분한다.
* 면접에서 협업 가능한 개발 습관을 보여준다.

이 프로젝트는 개인 프로젝트이지만 실무 협업 기준에 가깝게 Git 히스토리를 관리한다.

---

# Commit Principle

## One Commit, One Purpose

하나의 커밋은 하나의 목적만 가진다.

좋은 예시:

```text
feat: add medication schedule entity
```

```text
test: add SearchDrugUseCase tests
```

지양:

```text
fix everything
```

```text
update files
```

```text
feat: add calendar and fix API and update README
```

---

# Commit Message Format

기본 형식:

```text
type: summary
```

예시:

```text
feat: add drug search view model
```

```text
fix: handle empty drug search result
```

```text
docs: update architecture guide
```

---

# Commit Types

| Type       | Meaning                    |
| ---------- | -------------------------- |
| `feat`     | 새로운 기능 추가                  |
| `fix`      | 버그 수정                      |
| `refactor` | 기능 변화 없는 구조 개선             |
| `test`     | 테스트 추가/수정                  |
| `docs`     | 문서 추가/수정                   |
| `style`    | 포맷팅, 공백, 네이밍 등 동작 변화 없는 수정 |
| `chore`    | 빌드 설정, 패키지 관리, 기타 작업       |
| `build`    | 빌드 시스템, SPM, Xcode 설정 변경   |
| `perf`     | 성능 개선                      |
| `ci`       | CI 설정 변경                   |

---

# Commit Summary Rules

## Language

커밋 메시지는 영어로 작성한다.

이유:

* GitHub 포트폴리오 가독성
* 실무 convention과 유사
* 짧고 명확한 표현 가능

---

## Summary Style

규칙:

* 소문자로 시작
* 명령형 동사 사용
* 마침표 사용하지 않음
* 72자 이내 권장

좋은 예시:

```text
feat: add cycle record use case
```

```text
fix: prevent empty keyword API request
```

```text
refactor: separate drug dto mapper
```

지양:

```text
Feat: Added Cycle Record UseCase.
```

```text
fix: bug
```

```text
update
```

---

# Recommended Commit Flow

작업 단위 예시:

```text
feat: add health record entity
test: add HealthRecordUseCase tests
feat: implement health record repository
feat: add health record input view model
feat: add health record input screen
refactor: separate health record mapper
docs: update data model guide
```

이처럼 구현 흐름이 커밋 단위로 드러나게 작성한다.

---

# Branch Strategy

개인 프로젝트 기준으로 단순한 브랜치 전략을 사용한다.

## Main Branch

```text
main
```

역할:

* 항상 빌드 가능한 상태 유지
* README 기준 최신 상태 유지
* 포트폴리오 제출 기준 브랜치

---

## Feature Branch

형식:

```text
feature/short-description
```

예시:

```text
feature/drug-search
feature/medication-notification
feature/health-record
feature/calendar-bottom-sheet
```

---

## Fix Branch

형식:

```text
fix/short-description
```

예시:

```text
fix/drug-empty-state
fix/notification-cancel
```

---

## Docs Branch

형식:

```text
docs/short-description
```

예시:

```text
docs/readme
docs/architecture
```

---

# Branch Rules

규칙:

* `main`에는 직접 큰 작업을 하지 않는다.
* 기능 단위로 branch를 생성한다.
* 작업 완료 후 `main`에 merge한다.
* merge 전 build가 가능한 상태인지 확인한다.
* 너무 작은 수정은 main에서 직접 처리해도 되지만, 기능 작업은 branch를 사용한다.

---

# Pull Request Policy

개인 프로젝트라도 Pull Request처럼 작업 단위를 정리한다.

## PR Title Format

```text
[type] summary
```

예시:

```text
[feat] add drug search flow
```

```text
[test] add use case unit tests
```

---

## PR Description Template

```md
## Summary

- 구현 내용 요약

## Changes

- 변경 파일 또는 주요 변경 사항

## Test

- 실행한 테스트
- 수동 확인 내용

## Notes

- 남은 작업
- 의도적으로 제외한 작업
```

---

# Merge Policy

개인 프로젝트에서는 `Squash and Merge`를 기본으로 권장한다.

이유:

* main history를 깔끔하게 유지
* 기능 단위 히스토리 확인 가능
* 포트폴리오에서 보기 좋음

단, TDD 흐름을 보여주고 싶은 경우 일반 merge도 가능하다.

예:

```text
test: add failing SearchDrugUseCase tests
feat: implement SearchDrugUseCase
refactor: clean up search validation
```

이 흐름은 포트폴리오에서 TDD 근거로 활용 가능하다.

---

# Tag Policy

MVP 완료 시 tag를 생성한다.

예시:

```text
v1.0.0-mvp
```

권장 tag:

```text
v0.1.0-project-setup
v0.2.0-core-domain
v0.3.0-drug-search
v0.4.0-medication-flow
v1.0.0-mvp
```

---

# Issue Policy

GitHub Issue를 사용할 경우 다음 label을 사용한다.

| Label            | Meaning   |
| ---------------- | --------- |
| `feature`        | 기능 추가     |
| `bug`            | 버그 수정     |
| `refactor`       | 구조 개선     |
| `test`           | 테스트       |
| `docs`           | 문서        |
| `priority: high` | MVP 필수    |
| `priority: low`  | 후순위       |
| `phase2`         | MVP 이후 작업 |

---

# Issue Template

```md
## Description

작업 설명

## Scope

- 포함할 작업
- 제외할 작업

## Acceptance Criteria

- 완료 기준

## Notes

- 참고 사항
```

---

# GitHub Project Board

사용할 경우 다음 컬럼을 사용한다.

```text
Backlog
Todo
In Progress
Review
Done
```

개인 프로젝트라도 작업 상태를 시각화하면 포트폴리오 설명에 도움이 된다.

---

# Commit Examples by Feature

## Architecture

```text
chore: create project folder structure
feat: add dependency injection container
refactor: separate domain and data layers
docs: add architecture guide
```

---

## Drug Search

```text
feat: add drug entity
feat: add drug repository protocol
test: add SearchDrugUseCase tests
feat: implement drug search use case
feat: add drug api router
feat: implement drug repository
feat: add drug search view model
feat: add drug search view
fix: handle empty drug search result
```

---

## Medication

```text
feat: add medication entity
feat: add medication schedule model
test: add MedicationNotificationUseCase tests
feat: implement notification scheduling
feat: add medication list view model
feat: add medication list screen
fix: cancel notification when medication is disabled
```

---

## Health Record

```text
feat: add health record entity
test: add HealthRecordUseCase tests
feat: implement health record use case
feat: add health record input validation
feat: add health record list screen
```

---

## Calendar

```text
feat: add calendar view
feat: add date detail bottom sheet
feat: add cycle record entity
test: add CycleRecordUseCase tests
feat: implement retrieval record flow
feat: show medication events on calendar
```

---

# Build Check Before Commit

커밋 전 확인:

```bash
xcodebuild -scheme Aran
```

테스트 작성 작업이면:

```bash
xcodebuild test -scheme Aran
```

필요 시 destination 명시:

```bash
xcodebuild test \
  -scheme Aran \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

# Do Not Commit

커밋 금지:

* API Key
* Secret
* 개인정보
* DerivedData
* `.xcuserdata`
* 불필요한 debug log
* 임시 파일
* 대용량 녹화 원본 파일

---

# .gitignore Policy

포함 권장:

```gitignore
.DS_Store
DerivedData/
*.xcuserdata
*.xcuserstate
.env
*.log
```

API Key가 들어간 설정 파일은 원칙적으로 commit하지 않는다.

대신 예시 파일을 제공한다.

```text
Config.example.xcconfig
```

---

# Documentation Commit Policy

문서 변경도 명확한 커밋으로 남긴다.

예시:

```text
docs: add api integration guide
docs: update testing strategy
docs: document concurrency policy
```

---

# Refactoring Commit Policy

리팩토링 커밋은 기능 변경과 분리한다.

좋은 예시:

```text
refactor: extract drug mapper
```

지양:

```text
feat: add drug search and refactor repositories
```

규칙:

* 기능 추가와 구조 개선을 섞지 않는다.
* 리팩토링 후 테스트 또는 빌드 확인을 수행한다.

---

# Portfolio Principles

Git 히스토리는 개발자의 사고 과정을 보여주는 포트폴리오 자료다.

좋은 Git 히스토리는 다음을 보여준다.

* 작은 단위로 작업한다.
* 기능과 리팩토링을 분리한다.
* 테스트를 의식한다.
* 문서를 관리한다.
* MVP 범위를 통제한다.

목표:

* 면접관이 커밋만 봐도 개발 흐름을 이해할 수 있게 한다.
* 혼자 개발했지만 협업 가능한 방식으로 관리했다는 인상을 준다.
