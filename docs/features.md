# Features

## Product Scope

Aran is not a generic health app. It is scoped to IVF treatment management.

Prioritize:
- Treatment dates
- Medication/injection tracking
- Lab/test values
- Embryo retrieval/transfer records
- Drug information lookup
- Emotional diary attached to treatment context

## Tab 1: Calendar

Stack: SwiftUI + Combine

Role: Main hub for date-based treatment data.

Features:
- Monthly calendar view
- Color dots for hospital visit, ovulation, medication, transfer date, etc.
- Date tap opens bottom sheet
- Date detail shows records, medication, diary, test values
- Hospital schedule add/edit/delete
- Period start input and ovulation-date estimate
- Retrieval/transfer record input
- Emotional diary with emoji and text

Implementation notes:
- Use SwiftUI state for selected date and sheet presentation.
- Keep date calculation logic in Domain UseCases.
- Do not hard-code business calculations inside Views.

## Tab 2: Medication / Injection

Stack: UIKit + RxSwift

Role: Medication and injection schedule management.

Features:
- UITableView custom medication cells
- Medication name, dosage, type, schedule, checked state
- Swipe actions: delete / disable
- Disable keeps history but stops notifications
- Drug registration through shared DrugSearch register mode
- UserNotifications for reminder registration/update/delete
- RxSwift binding for medication check state

Implementation notes:
- Use `Driver` for UI-safe output streams.
- Use `PublishRelay` for user actions.
- Use `BehaviorRelay` for mutable view state when needed.
- Notification IDs should be stable and stored with medication schedule data.

## Tab 3: Health Test Records

Stack: UIKit + RxSwift

Role: IVF-related health test values and history.

Features:
- Test value input form
- Test item picker: FSH, AMH, AFC, E2, progesterone, etc.
- Numeric validation with save-button enablement
- Date picker
- Item-specific history table
- PGT result entry: normal / abnormal / mosaic counts
- Couple chromosome result text entry
- Implantation-related test result recording

Implementation notes:
- Validate numeric input in ViewModel.
- Keep thresholds and interpretation out of UI unless explicitly modeled.
- Charts are optional polish, preferably with Swift Charts if used.

## Tab 4: Drug Information

Stack: SwiftUI + Combine

Role: Drug search and detail lookup.

Features:
- Drug name search
- Combine debounce, default 0.3 seconds
- API result list
- Drug detail screen with efficacy, usage, warnings, interaction, side effects, storage
- Loading, empty, and error states
- Browse mode for drug information tab
- Register mode reused from medication tab

Implementation notes:
- `DrugSearchView` should support `browse` and `register` modes.
- API empty result should show direct-input fallback when used in register mode.
- Network errors should support retry and fallback guidance.
