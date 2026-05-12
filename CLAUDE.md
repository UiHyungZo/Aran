# CLAUDE.md

Claude Code should read this file first. Keep it short. Detailed project rules live in `docs/`.

## Absolute Rules

- Always respond in Korean unless the user explicitly requests another language.
- Before modifying files, explain the plan and list the files likely to change.
- Do not modify files until the user approves the plan for non-trivial changes.
- Do not delete files, rename targets, change bundle identifiers, or modify Xcode project settings unless explicitly requested.
- Do not add third-party dependencies without explicit approval.
- Do not hard-code API keys, secrets, or personal information.
- Keep changes small, reviewable, and buildable.
- If requirements are ambiguous, ask a clarification question before implementing.
- If this file conflicts with any document in `docs/`, this file takes priority.

## Project

**Aran** is an iOS portfolio app for IVF treatment management.

Core scope:

- Calendar-based IVF treatment tracking
- Medication/injection schedule and notifications
- Health test value recording and history
- Drug search/detail lookup through MFDS e약은요 API
- Interview-explainable Clean Architecture + MVVM implementation

## Tech Stack

- Platform: iOS / iPhone
- Language: Swift
- Architecture: Clean Architecture + MVVM
- UI: UIKit + RxSwift and SwiftUI + Combine hybrid
- Local DB: SwiftData
- Network: Alamofire + async/await
- API: MFDS e약은요 OpenAPI
- Notifications: UserNotifications
- Dependency Manager: Swift Package Manager
- Tests: XCTest / XCUITest

## Architecture Summary

Use this dependency direction only:

```text
Presentation -> Domain <- Data

## Detailed Rules

Read docs/ before starting any task:
- docs/architecture.md — folder structure and layer rules
- docs/features.md — tab features and implementation notes
- docs/api.md — API spec and fallback policy
- docs/coding-style.md — naming and reactive conventions
- docs/testing.md — test strategy and mock structure
