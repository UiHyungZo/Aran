# Testing

## Strategy

Testing should demonstrate why Clean Architecture was chosen.

Core logic should be testable with mock repositories and without UI, network, database, or notification side effects.

## Unit Tests

Framework: XCTest

Primary targets:
- Domain UseCases
- ViewModels with reactive binding logic
- Repository implementations where useful

Recommended test style:

```text
given -> when -> then
```

## UseCase Test Targets

| Area | Example Test File | Coverage |
|---|---|---|
| Drug search | `SearchDrugUseCaseTests` | success, empty keyword, network failure propagation |
| Cycle records | `CycleRecordUseCaseTests` | save retrieval, query by cycle, update transfer result |
| Medication notifications | `MedicationNotificationUseCaseTests` | create, update, cancel on disable |
| Health records | `HealthRecordUseCaseTests` | save value, item history, date sorting |

## Mock Repositories

Create mock implementations for repository protocols.

Examples:
- `MockDrugRepository`
- `MockMedicationRepository`
- `MockHealthRecordRepository`
- `MockCycleRecordRepository`
- `MockNotificationRepository`

Mocks should support:
- Stubbed success values
- Stubbed errors
- Captured input parameters
- Call-count verification when meaningful

## UI Tests

Framework: XCUITest

Focus on essential user flows, not exhaustive UI coverage.

Scenarios:
- Calendar date tap opens bottom sheet
- Medication registration through search flow
- Notification setting save flow
- Drug search result to detail flow
- Transfer/retrieval record input and calendar reflection

## Coverage Targets

| Layer | Target |
|---|---|
| Domain / UseCases | 80%+ |
| Data / Repositories | 60%+ |
| Presentation / ViewModels | 50%+ |
| UI Tests | 5 core scenarios |

Coverage is less important than proving that architecture enables isolated tests.
