# 보안 이슈 목록

보안 감사(2026-05-29) 결과 발견된 이슈. 우선순위 순 정렬.

---

## 🔴 CRITICAL

### [ ] API 키 `project.pbxproj` 하드코딩 제거
- **파일**: `Aran.xcodeproj/project.pbxproj` (lines 309–311, 345–347)
- **내용**: `DRUG_API_DECODING`, `DRUG_API_ENCODING` 실제 키 값이 pbxproj에 직접 포함됨
- **해결**:
  1. `Secrets.xcconfig` 로 키 분리 후 `.gitignore` 에 추가
  2. `Secrets.xcconfig.template` 은 저장소에 남겨 설정 가이드 제공

---

## 🟠 HIGH

### [ ] SwiftData 파일 보호 속성 미설정
- **파일**: `Aran/Application/SceneDelegate.swift`
- **내용**: `ModelConfiguration` 생성 시 파일 보호 속성 미지정
- **해결**: `makeModelContainer()` 에서 `ModelContainer` 생성 성공 후, store 관련 파일 3개(`default.store`, `-wal`, `-shm`)에 FileManager로 보호 속성 적용

```swift
// makeModelContainer() 내부, ModelContainer 생성 직후
let relatedURLs = [
    storeURL,
    storeDirectory.appending(path: "\(storeFileName)-shm"),
    storeDirectory.appending(path: "\(storeFileName)-wal")
]
for url in relatedURLs where fileManager.fileExists(atPath: url.path) {
    try? fileManager.setAttributes(
        [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
        ofItemAtPath: url.path
    )
}
```

### [ ] 마이그레이션 실패 시 조용한 데이터 삭제
- **파일**: `Aran/Application/SceneDelegate.swift` — `makeModelContainer()` catch 블록
- **내용**: 마이그레이션 실패 시 경고 없이 로컬 데이터 삭제 → 사용자 데이터 손실 리스크
- **해결**: catch 블록에 `#if DEBUG` 로그 추가 (사용자 UX 안내는 SceneDelegate 범위를 벗어나므로 로그만 처리)

```swift
} catch {
    #if DEBUG
    print("[SceneDelegate] 마이그레이션 실패, 저장소 초기화: \(error)")
    #endif
    resetLocalStore(at: storeURL)
    return try ModelContainer(for: schema, configurations: [configuration])
}
```

---

## 🟡 MEDIUM

### [ ] 알림 본문에 민감 정보 노출
- **파일**: `Aran/Data/Notification/NotificationManager.swift` (line 16)
- **내용**: 잠금 화면 알림에 약 이름/용량이 그대로 표시됨
- **해결**: 알림 본문을 일반 문구로 변경

```swift
// before
content.body = "\(medication.drugName) \(medication.dosage) 복용 시간입니다."

// after
content.body = "복용 시간입니다. 앱에서 상세 내용을 확인하세요."
```

### [ ] `print()` 로 에러 콘솔 출력 (릴리즈 빌드 포함)
- **파일**: `Aran/Data/Local/Mappers/CycleRecordMapper.swift` (lines 54, 64)
- **내용**: 직렬화 에러가 릴리즈 빌드에서도 콘솔에 출력됨
- **해결**: 두 `print()` 문 모두 `#if DEBUG ... #endif` 로 감싸기

```swift
#if DEBUG
print("[CycleRecordMapper] 이벤트 역직렬화 실패: \(error)")
#endif
```

### [ ] 건강 수치 상한값 검증 없음
- **파일**: `Aran/Domain/UseCases/HealthRecordUseCase.swift` (lines 34–35)
- **내용**: `value > 0` 만 체크, 상한 없음 / NaN·Infinity 미검증
- **해결**: `type`이 String 자유 입력이므로 타입별 분기 대신 범용 상한값 + 특수값 검증 추가

```swift
guard !value.isNaN, !value.isInfinite else {
    throw AppError.invalidInput("유효하지 않은 수치입니다.")
}
guard value > 0 else {
    throw AppError.invalidInput("유효한 수치를 입력해주세요.")
}
guard value < 999_999 else {
    throw AppError.invalidInput("수치가 허용 범위를 초과했습니다.")
}
```

### [ ] SearchDrugUseCase 입력 검증 부재
- **파일**: `Aran/Domain/UseCases/SearchDrugUseCase.swift`
- **내용**: `pageNo < 1`, 너무 긴 검색어, 빈 `itemSeq` 검증 없음 (빈 검색어는 이미 처리됨)
- **해결**: 각 파라미터 경계값 검증 추가

```swift
func execute(keyword: String, pageNo: Int = 1) async throws -> DrugSearchResult {
    let trimmed = keyword.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { throw AppError.invalidInput("검색어를 입력해주세요.") }
    guard trimmed.count <= 100 else { throw AppError.invalidInput("검색어가 너무 깁니다.") }
    guard pageNo >= 1 else { throw AppError.invalidInput("올바르지 않은 페이지 번호입니다.") }
    return try await repository.search(keyword: keyword, pageNo: pageNo)
}

func detail(itemSeq: String) async throws -> Drug {
    guard !itemSeq.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw AppError.invalidInput("약품 코드가 올바르지 않습니다.")
    }
    return try await repository.detail(itemSeq: itemSeq)
}
```

### [ ] UserDefaults에 검색 기록 평문 저장
- **파일**: `Aran/Presentation/DrugInfo/DrugInfoViewModel.swift` (lines 136–186)
- **내용**: 최근 검색어, 즐겨찾기 ID를 `UserDefaults.standard` 에 저장 (암호화 없음)
- **판단**: 민감도 낮음 — 현재 UX(전체 삭제 기능) 유지하되 추후 개선 고려

---

## 🔵 LOW / INFO

### [ ] 인증서 피닝 미구현
- **내용**: Alamofire `Session.default` 사용, `ServerTrustManager` 없음
- **판단**: 공공 API 인증서 변경 리스크 있어 MVP 제외, 추후 고려

### [ ] ATS 명시적 설정 없음
- **파일**: `Aran/Info.plist`
- **내용**: `NSAppTransportSecurity` 키 없음. iOS 기본값이 이미 `NSAllowsArbitraryLoads = false`(HTTPS만 허용)이므로 동작 변경 없음. `true`가 HTTP 허용, `false`가 HTTPS 강제임에 유의
- **해결**: 명시적 선언으로 설정 의도를 문서화 (동작 변경 없이 가독성 향상 목적)

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### [ ] 앱 레벨 생체 인증 없음
- **내용**: Face ID / Touch ID / PIN 없음 — 기기 접근 시 모든 데이터 열람 가능
- **판단**: UX 영향이 큰 별도 기능 → 1차 보안 수정 범위 제외, 별도 기능으로 계획

---

## 관련 테스트 추가 항목

### SearchDrugUseCaseTests
- 빈 검색어 → `invalidInput` throw
- 공백만 있는 검색어 → `invalidInput` throw
- 101자 검색어 → `invalidInput` throw
- `pageNo = 0` → `invalidInput` throw
- 빈 `itemSeq` → `invalidInput` throw

### HealthRecordUseCaseTests
- NaN → `invalidInput` throw
- Infinity → `invalidInput` throw
- 0 이하 → `invalidInput` throw
- 999999 이상 → `invalidInput` throw

### DrugRouterTests
- API 키와 검색어가 URL query에서 올바르게 인코딩되는지 확인
