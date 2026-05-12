# Architecture

## Goal

Aran uses Clean Architecture + MVVM to keep business logic testable and independent from UI, database, networking, and notification frameworks.

## Folder Structure

```text
Aran
├── Presentation
│   ├── Calendar          // SwiftUI + Combine
│   ├── Medication        // UIKit + RxSwift
│   ├── HealthRecord      // UIKit + RxSwift
│   ├── DrugInfo          // SwiftUI + Combine
│   └── Common
│       ├── Bridging
│       └── DesignSystem
├── Domain
│   ├── Entities
│   ├── UseCases
│   └── Repositories      // Protocols only
├── Data
│   ├── Repositories      // Implementations
│   ├── Local             // SwiftData
│   ├── Network           // Alamofire Router
│   └── Notification      // UserNotifications
└── Tests
    ├── UnitTests
    └── UITests
```

## Dependency Direction

```text
Presentation -> Domain <- Data
```

Presentation and Data both depend on Domain. Domain depends on nothing app-specific.

## Presentation Layer

Contains:
- SwiftUI Views
- UIKit ViewControllers
- ViewModels
- Cells and view components
- Navigation/presentation coordination

Allowed dependencies:
- Domain
- Combine for SwiftUI features
- RxSwift/RxCocoa for UIKit features
- UIKit/SwiftUI as appropriate

Forbidden:
- Direct SwiftData access
- Direct Alamofire calls
- Direct UserNotifications calls
- Business rules inside Views or ViewControllers

## Domain Layer

Contains:
- Entities
- UseCases
- Repository protocols
- Domain-specific errors

Forbidden:
- UIKit
- SwiftUI
- Combine
- RxSwift
- SwiftData
- Alamofire
- UserNotifications

## Data Layer

Contains:
- Repository implementations
- SwiftData models/mappers
- Alamofire router/API clients
- UserNotifications integration

Rules:
- Convert DTOs and SwiftData models into Domain Entities before returning upward.
- Do not expose DTOs to Domain or Presentation.
- Handle infrastructure errors and map them to domain/application errors.

## Bridging

Use bridging only where it demonstrates intentional stack boundaries.

Examples:
- `UIHostingController`: present `DrugSearchView` from UIKit medication registration flow.
- `UIViewRepresentable`: embed a UIKit component inside SwiftUI only if necessary.

Avoid bridge code for trivial UI that could stay within the feature's chosen stack.
