# Coding Style

## General Swift Rules

- Prefer explicit, descriptive names.
- Keep files small and feature-scoped.
- Avoid global singletons unless the platform API requires a shared instance wrapper.
- Prefer dependency injection through initializers.
- Keep DTO, SwiftData model, and Domain entity types separate.

## Naming

Suggested suffixes:
- `View` for SwiftUI views
- `ViewController` for UIKit screens
- `ViewModel` for presentation state and actions
- `UseCase` for domain operations
- `RepositoryProtocol` for domain interfaces
- `Repository` for data implementations
- `DTO` for API response/request types
- `Model` for SwiftData persistence types
- `Mapper` for conversion helpers

## Reactive Conventions

### SwiftUI + Combine

Use:
- `@Published`
- `@StateObject`
- `PassthroughSubject`
- `.debounce()`
- `.catch()` / `.replaceError()` where appropriate

Avoid:
- API calls directly in Views
- Business logic inside SwiftUI body

### UIKit + RxSwift

Use:
- `PublishRelay` for user actions
- `BehaviorRelay` for current mutable state
- `Driver` for UI output
- `DisposeBag` per ViewController / reusable cell lifecycle

Avoid:
- Binding raw `Observable` directly to UI when `Driver` is safer
- Retain cycles in subscriptions
- Validation logic inside ViewController

## Error Handling

- Model expected errors explicitly.
- Empty API search result is not a crash/fatal error.
- Network error should expose retry/fallback state.
- Invalid user input should be handled through validation state, not thrown exceptions.

## Portfolio-Oriented Code

This app is a portfolio project. Prefer clarity over clever abstraction.

Good signs:
- A reviewer can explain the dependency graph quickly.
- UseCases can be tested with mocks.
- UIKit/RxSwift and SwiftUI/Combine choices are intentional.
- Bridging code has a clear reason.
- API fallback behavior is visible and user-friendly.

Avoid:
- Overengineering generic frameworks
- Mixing two reactive systems inside the same feature without a boundary
- Putting all logic into ViewModels
- Creating abstractions that are not used by at least one concrete feature or test
