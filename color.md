# Aran 컬러 시스템 작업 지시 (color.md)

> 대상: Codex. 목표: **라이트 모드를 첨부 목업과 동일하게 만들고**, 동시에 **다크모드를 디자인된 값으로 대응**한다. 방식은 **Asset Catalog semantic color(Light/Dark 두 벌) + `AranColor` 토큰을 화면에 배선**.

## 0. 현재 상태 (출발점)
- 다크모드 1차 작업은 커밋됨(`379db92 feat : 다크모드 대응`). `Aran/Assets.xcassets`에 다음 컬러셋이 **Light/Dark 두 벌**로 존재: `primaryColor`, `backgroundColor`, `secondaryColor`, `dotDiary`, `dotHospital/Medication/Ovulation/Period/PeriodPredicted/Retrieval/Transfer/HealthRecord`, `badge*`.
- 토큰 파일: `Aran/Presentation/Common/DesignSystem/Colors.swift` (`enum AranColor`). 이미 에셋 참조로 정리됨(`primary = Color("primaryColor")` 등).
- **문제 1**: 토큰이 실제 화면에 거의 안 쓰여서, 라이트가 목업(크림 배경 + 탭별 액센트)이 아니라 **흰 배경**(`Color(.systemBackground)`)으로 보인다.
- **문제 2**: 다크 값은 알고리즘 추측치(디자인된 값 아님).

## 1. 디자인 원칙 (목업에서 도출)
- 배경은 **크림** 단색, 카드/시트는 **흰색**, 텍스트는 시스템 `label`/`secondaryLabel`.
- **탭마다 고유 액센트 1색**(버튼·강조·탭 하이라이트). 액센트는 **채도가 낮은 무드**(목업은 소프트/뮤트 톤)다.
- 주의: 기존 `dot*` 에셋은 **달력 마커 전용의 비비드 색**이다. **버튼/강조에는 dot 색을 재사용하지 말고** 아래 액센트 토큰을 쓴다(목업의 뮤트 톤과 다름).

## 2. 컬러 토큰 정의 (Light = 목업 추출, Dark = 제안값)

> 라이트 값은 첨부 라이트 목업 기준. 다크 값은 제안이며, **다크 목업이 제공되면 그 값으로 교체**한다. RGB는 0–1(에셋 components) / HEX 병기.

### 공통(Surface/Text)
| 토큰(에셋명) | 용도 | Light | Dark(제안) |
|---|---|---|---|
| `backgroundColor` | 앱 전체 배경(크림) | `#F4F2ED` (0.957,0.949,0.929) — *현재 값 유지* | `#171719` (0.090,0.090,0.098) |
| `surfaceColor` (신규) | 카드/시트 배경 | `#FFFFFF` (1,1,1) | `#1E1E20` (0.118,0.118,0.125) |
| `dividerColor` (신규, 선택) | 구분선 | `#E7E3DA` (0.906,0.890,0.855) | `#2C2C2E` (0.173,0.173,0.180) |

### 탭별 액센트 (Light = 목업, Dark = 제안)
| 토큰(에셋명) | 탭 | Light HEX | Light RGB(0–1) | Dark HEX(제안) | 비고 |
|---|---|---|---|---|---|
| `primaryColor` | 캘린더 | `#C04A6E` | 0.753, 0.290, 0.431 — *현재 값 유지* | `#E0738F` | 로즈 |
| `accentMedication` (신규) | 약/주사 | `#5B4FCF` | 0.357, 0.310, 0.812 | `#9A8FF0` | 인디고(버튼). 점은 기존 `dotMedication` 유지 |
| `accentHealth` (신규) | 검사 | `#2F6FE0` | 0.184, 0.435, 0.878 | `#6FA0F0` | 블루(버튼/수치). 기존 `dotHealthRecord`(#186BA5)보다 밝음 |
| `accentProcedure` (신규) | 시술 | `#4E8E63` | 0.306, 0.557, 0.388 | `#73C28C` | 세이지 그린(버튼). 점은 기존 `dotTransfer` 유지 |
| `accentDrug` (신규) | 약정보 | `#3A5A1E` | 0.227, 0.353, 0.118 | `#8CB36A` | 딥 포레스트/올리브(버튼) |

### 액센트 보조(칩/연한 배경) — opacity로 처리 권장
- 칩 배경은 해당 액센트 `.opacity(0.12~0.15)`, 칩 텍스트는 액센트 원색. 별도 에셋 없이 `AranColor.accentX.opacity(...)`로.
- 예: `procedureChipBackground`(이미 `Colors.swift`에 패턴 존재)와 동일 방식.

## 3. `AranColor` 토큰 추가 (`Aran/Presentation/Common/DesignSystem/Colors.swift`)
```swift
// 추가
static let surface = Color("surfaceColor")
static let accentMedication = Color("accentMedication")
static let accentHealth = Color("accentHealth")
static let accentProcedure = Color("accentProcedure")
static let accentDrug = Color("accentDrug")

// UIKit 변형(약/주사·검사 탭이 UIKit이므로 필요)
static let accentMedicationUI = UIColor(named: "accentMedication")!
static let accentHealthUI = UIColor(named: "accentHealth")!
static let accentProcedureUI = UIColor(named: "accentProcedure")!
static let accentDrugUI = UIColor(named: "accentDrug")!
static let surfaceUI = UIColor(named: "surfaceColor")!
// backgroundUI 는 이미 존재: UIColor(named: "backgroundColor") ?? .systemBackground
```

## 4. 화면 배선 (라이트 예쁨의 핵심 — 토큰을 실제로 적용)

### 패턴 A — 루트 배경을 크림으로
`Color(.systemBackground)` / `.systemGroupedBackground`로 흰 배경이 나오는 **탭 루트**를 `AranColor.background`로 교체.
- SwiftUI: `Presentation/Common/MainTabView.swift:123`, `Calendar/CalendarView.swift:312,589`, `ProcedureRecord/ProcedureRecordView.swift`, `DrugInfo/*View.swift`, `Common/DrugSearch/DrugSearchView.swift`.
- UIKit: `Medication/MedicationListViewController.swift`(`view`/`tableView` backgroundColor), `HealthRecord/ExamListViewController.swift`, `ExamHistoryViewController.swift`, `Medication/NotificationSettingsViewController.swift` → `AranColor.backgroundUI`.

### 패턴 B — 카드/셀/시트는 surface(흰색)
카드·셀·바텀시트 배경을 `AranColor.surface`(SwiftUI) / `AranColor.surfaceUI`(UIKit)로.
- `Medication/MedicationCell.swift:22-23`, `HealthRecord/ExamListCell.swift:27-28`, `Calendar/DateDetailSheet.swift`, `CalendarView.swift`의 카드, `ProcedureRecord`의 카드들.

### 패턴 C — 탭별 액센트 적용
각 탭의 주요 버튼/강조/선택 상태를 해당 액센트 토큰으로.
- 캘린더: 선택 원·저장 버튼 = `AranColor.primary` (대부분 이미 적용됨, 확인만).
- 약/주사(UIKit): `MedicationFormViewController.swift`의 `saveButton.backgroundColor`, `startDatePicker.tintColor` 등 `AranColor.primaryUI` → `accentMedicationUI`. 삭제 버튼은 `badgeFailed*` 재사용.
- 검사(UIKit): 수치 텍스트/+버튼/입력 칩을 `accentHealthUI` 계열. (현재 `Colors.swift`의 `healthRecord*UI` 토큰 활용/정리).
- 시술(SwiftUI): 저장 버튼·강조 = `AranColor.accentProcedure`, 칩 = `.opacity(0.12)`.
- 약정보(SwiftUI): "이 약 추가하기" 버튼 = `AranColor.accentDrug`, 칩/연배경 = `.opacity(0.12)`. `DrugSearchView.swift:144`의 `Color.green.opacity(0.1)`, `DrugDetailView.swift:90`의 `Color.orange.opacity(0.08)`도 토큰화.

### 패턴 D — 탭바 정체성
`MainTabView.swift:137-148`: 선택 탭 색을 **현재 탭의 액센트**로(목업처럼 탭마다 색이 다름). 단순화를 위해 선택 시 `AranColor.primary` 고정도 허용하나, 목업은 탭별 색이므로 액센트 매핑 권장.

## 5. Swift Charts
- `HealthRecord/ExamChartView.swift`: 막대/라인 = `AranColor.accentHealth`(또는 기존 `dotHealthRecord`), 배경 `.clear` 유지.
- `ProcedureRecord/ProcedureChartView.swift`: 단계별 = `AranColor.accentProcedure`의 opacity 단계(0.4/0.6/0.8/1.0). 축·레전드는 `.secondary`.

## 6. 하드코딩 색 제거 (다크에서 깨지는 지점)
- `Medication/MedicationCell.swift:93,95`(주사/패치 색), `MedicationFormViewController.swift:102-103,346`, `MedicationListViewController.swift`(swipe 색)의 `UIColor(red:...)` → 토큰 또는 `.systemGray`/dynamic.
- `Colors.swift`의 잔여 하드코딩 RGB는 토큰/시스템 semantic로.

## 7. 작업 순서 (권장)
1. 신규 컬러셋 5개 생성(`surfaceColor`, `accentMedication/Health/Procedure/Drug`) Light/Dark. → `Aran/Assets.xcassets/badgeSuccessBackground.colorset/Contents.json` 구조 복제.
2. `Colors.swift`에 토큰 추가.
3. 패턴 A(배경) → B(카드) → C(액센트) → D(탭바) 순으로 화면 배선.
4. 차트/하드코딩 정리.
5. 다크 목업 제공 시, 각 컬러셋의 dark 값을 목업 추출값으로 교체.

## 8. 컬러셋 JSON 템플릿 (참고)
신규 `*.colorset/Contents.json`은 아래 구조로(Light/Dark 두 벌). `components` 값만 교체.
```json
{
  "colors": [
    {
      "appearances": [ { "appearance": "luminosity", "value": "light" } ],
      "color": { "color-space": "srgb", "components": { "red": "0.357", "green": "0.310", "blue": "0.812", "alpha": "1.000" } },
      "idiom": "universal"
    },
    {
      "appearances": [ { "appearance": "luminosity", "value": "dark" } ],
      "color": { "color-space": "srgb", "components": { "red": "0.604", "green": "0.561", "blue": "0.941", "alpha": "1.000" } },
      "idiom": "universal"
    }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

## 9. 검증
- 빌드(스크립트 `scripts/build-debug.sh`의 Xcode 경로가 26.4.0 하드코딩이라 환경변수로 우회):
  ```bash
  DEVELOPER_DIR=/Applications/Xcode-26.4.1.app/Contents/Developer \
    xcodebuild -project Aran.xcodeproj -scheme Aran -configuration Debug \
    -destination 'generic/platform=iOS Simulator' build
  ```
- 라이트/다크 각각 5개 탭(캘린더/약·주사/검사/시술/약정보)을 목업과 육안 대조.
- 회귀(색 변경은 로직 무관, 기존 PASS 유지). iOS 26.4 런타임 시뮬레이터 사용:
  ```bash
  DEVELOPER_DIR=/Applications/Xcode-26.4.1.app/Contents/Developer \
    xcodebuild test -project Aran.xcodeproj -scheme Aran \
    -destination 'platform=iOS Simulator,id=<iOS 26.4 기기 UDID>' \
    -only-testing:AranTests
  ```

## 10. 제약 / 규칙 (CLAUDE.md 준수)
- Domain 레이어 색 의존 금지. 색은 Presentation에만.
- 변경은 색/배선과 직접 관련된 라인만(surgical). 무관한 리팩토링 금지.
- API Key 등 하드코딩 금지(해당 없음).
- 다크 값은 추측 최소화 — 가능하면 목업 추출값 사용.
- 파일 삭제/이름 변경/프로젝트 설정 변경은 사용자 승인 후.

## 11. BLOCKER / 결정 필요
- **다크 목업 이미지**가 제공되면 §2의 Dark 열을 그 값으로 교체(현재 제안값은 디자인 추측). 라이트만 우선 마감도 가능. → **해소: §12 참조**(다크 목업 5탭 제공됨, 추출값 확정).
- §2의 액센트 Light HEX는 목업에서 시각 추출한 근사값 — 정확한 디자인 토큰(피그마 등)이 있으면 그 값 우선.

## 12. 다크 목업 추출값 (확정 — §2 Dark 열 교체)

> 출처: 사용자 제공 다크 목업 5탭(캘린더/약·주사/검사/시술/약정보). 육안 추출 근사값.
> 본 섹션 값이 §2의 Dark(제안) 열을 **대체**한다. 에셋 colorset의 dark components를 아래로 설정.

### 공통 Surface/Text
| 토큰 | Dark HEX | Dark RGB(0–1) |
|---|---|---|
| backgroundColor | #1A1A1C | 0.102, 0.102, 0.110 |
| surfaceColor    | #262628 | 0.149, 0.149, 0.157 |
| dividerColor    | #38383A | 0.220, 0.220, 0.227 |

### 탭별 액센트
| 토큰 | 탭 | Dark HEX | Dark RGB(0–1) |
|---|---|---|---|
| primaryColor      | 캘린더  | #E07A93 | 0.878, 0.478, 0.576 |
| accentMedication  | 약/주사 | #9C92F2 | 0.612, 0.573, 0.949 |
| accentHealth      | 검사    | #6EA0F2 | 0.431, 0.627, 0.949 |
| accentProcedure   | 시술    | #79C48E | 0.475, 0.769, 0.557 |
| accentDrug        | 약정보  | #93BA6E | 0.576, 0.729, 0.431 |

> 정밀 보정 필요 시: 목업 PNG를 픽셀 샘플링(예: macOS 디지털 컬러 측정기)해 위 components만 교체.
