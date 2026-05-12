# API

## External API

Use MFDS 의약품개요정보, also known as e약은요 OpenAPI.

Base URL:

```text
https://apis.data.go.kr/1471000/DrbEasyDrugInfoService
```

Purpose:
- Drug name search
- Drug detail lookup
- Display efficacy, usage, warnings, interactions, side effects, and storage information

## Main Endpoints

| Endpoint | Purpose | Router Case |
|---|---|---|
| `getDrbEasyDrugList` | Search by `itemName` | `DrugRouter.search(keyword:pageNo:)` |
| `getDrbEasyDrugInfo` | Detail lookup by `itemSeq` | `DrugRouter.detail(itemSeq:)` |

## Useful Response Fields

| Field | Meaning | App Usage |
|---|---|---|
| `itemSeq` | Item sequence code | Detail lookup key |
| `itemName` | Product name | Search result / medication prefill |
| `entpName` | Company name | List/detail display |
| `efcyQesitm` | Efficacy | Detail section |
| `useMethodQesitm` | Usage | Detail section |
| `atpnWarnQesitm` | Warning | Warning banner |
| `atpnQesitm` | Precautions | Detail section |
| `intrcQesitm` | Interaction | Detail section |
| `seQesitm` | Side effects | Detail section |
| `depositMethodQesitm` | Storage | Detail section |
| `itemImage` | Drug image URL | Optional image display |

## Router Design

Use Alamofire `URLRequestConvertible`.

Expected cases:

```swift
enum DrugRouter: URLRequestConvertible {
    case search(keyword: String, pageNo: Int)
    case detail(itemSeq: String)
}
```

Rules:
- Use GET.
- Include `serviceKey` securely through configuration.
- Do not hard-code secrets.
- Keep query parameter construction inside the router.
- Decode API DTOs in Data layer.
- Map DTOs to Domain entities before returning to UseCases.

## Fallback Policy

IVF medications may include prescription drugs that are missing from e약은요 results.

Handle these cases:

| Case | UX |
|---|---|
| API result exists | Select result and prefill medication form |
| Empty result | Show “직접 입력하기” fallback |
| Network error | Show retry, then fallback guidance |
| Empty keyword | Do not call API |

Do not treat empty result as a fatal error. It is an expected product case.
