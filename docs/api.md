# API

## Goal

Aran은 외부 API와 내부 데이터 흐름을 명확히 분리한다.

목표:

* API 의존성 캡슐화
* DTO와 Domain Entity 분리
* 테스트 가능한 Repository 구조 유지
* Empty Result와 Network Error를 정상 UX 흐름으로 처리
* Swift 6 async/await 기반 네트워크 구조 유지

---

# External API

## MFDS e약은요 OpenAPI

식품의약품안전처 의약품개요정보 API 사용.

용도:

* 약 이름 검색 (fallback)
* 효능·용법·주의사항 등 임상 정보 취득
* 성분명 자동 입력
* 약 등록 자동화

---

## 의약품허가정보서비스 (DrugPrdtPrmsnInfoService07)

식품의약품안전처 의약품 허가 정보 조회 API.

용도:

* 전문의약품 검색 (primary)
* 허가정보(허가일자, 주성분, EDI코드 등) 취득
* 임상 정보(XML 파싱: 효능·용법·주의사항) 취득
* e약은요 fallback 전 우선 조회

---

# Base URL

## e약은요

```text
https://apis.data.go.kr/1471000/DrbEasyDrugInfoService
```

## 의약품허가정보서비스

```text
https://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService07
```

---

# API Endpoints

## e약은요 Drug Search

약 이름 검색 (fallback).

엔드포인트:

```text
getDrbEasyDrugList
```

용도:

* 약 이름 검색
* register mode
* browse mode (전문의약품 결과 없을 때 fallback)

예시:

```text
프로게스테론
에스트라디올
```

---

## 허가정보 Drug Search

전문의약품 검색 (primary).

엔드포인트:

```text
getDrugPrdtPrmsnInq07
```

용도:

* 약 이름 검색 (primary — e약은요보다 우선 조회)
* 허가정보 + 임상정보(XML 파싱) 취득
* 결과 없을 시 e약은요로 fallback

---

## 허가정보 Drug Detail

허가정보 API 검색 응답에 효능, 용법 등 본문 필드가 부족할 때만 단건 상세 조회로 보강한다. e약은요 fallback 결과는 검색 응답을 상세 화면에 바로 표시한다.

엔드포인트:

```text
getDrugPrdtPrmsnDtlInq06
```

용도:

* 효능 (eeDocData XML 파싱)
* 용법·용량 (udDocData XML 파싱)
* 주의사항·경고 (nbDocData XML 파싱)
* 허가정보 보강

---

# Network Architecture

## Layer Flow

```text
Presentation
→ UseCase
→ Repository Protocol
→ Repository
→ APIClient
→ Router
→ External API
```

---

# Responsibilities

## Presentation

역할:

* 검색 키워드 전달
* Loading/Error 상태 표시
* 결과 화면 표시

금지:

* Alamofire 직접 호출
* DTO 직접 사용
* URLSession 직접 사용

---

## UseCase

역할:

* 검색 실행
* 입력 검증
* 비즈니스 규칙 처리

예시:

```text id="8tyi8f"
빈 검색어 차단
최소 2자 입력 제한
```

---

## Repository

역할:

* API 호출
* DTO decode
* Entity 변환
* Error 변환

규칙:

* DTO를 외부로 노출하지 않는다.
* Domain Entity만 반환한다.

---

## Infrastructure

역할:

* Alamofire 요청 생성
* Router 관리
* Request/Response 처리
* HTTP 상태 코드 처리

---

# API Client Policy

## APIClient

API 요청 공통 처리 객체.

역할:

* Request 실행
* 공통 Error 처리
* JSON decode
* Status Code 검증

예시:

```swift
protocol APIClientProtocol {
    func request<T: Decodable>(
        _ router: URLRequestConvertible
    ) async throws -> T
}
```

규칙:

* async/await 기반 구현
* Alamofire 세부 구현 캡슐화
* 공통 decode 처리
* 중복 request 코드 제거

---

# Router Policy

## DrugRouter (e약은요)

Alamofire `URLRequestConvertible` 사용.

```swift
enum DrugRouter {
    case search(keyword: String, pageNo: Int, serviceKey: String, baseURL: String)
}
```

## DrugApprovalRouter (의약품허가정보서비스)

```swift
enum DrugApprovalRouter {
    case search(itemName: String, pageNo: Int, serviceKey: String, baseURL: String)
    case detail(itemSeq: String, serviceKey: String, baseURL: String)
}
```

역할:

* path 생성
* query parameter 구성
* HTTP method 설정
* encoding 처리

규칙:

* URL 생성 로직을 ViewModel에 두지 않는다.
* query parameter 하드코딩 금지
* endpoint별 Router case 분리

---

# Request Policy

## HTTP Method

모든 e약은요 API 요청은 GET 사용.

```text id="twivdp"
GET
```

---

## Query Parameters

예시:

```text
serviceKey
itemName
pageNo
numOfRows
type
```

규칙:

* API Key는 코드에 하드코딩하지 않는다.
* parameter key 문자열 중복 최소화
* URL Encoding 처리 필수

---

# API Key Policy

## Configuration

API Key는 별도 configuration에서 관리한다.

허용:

* xcconfig
* plist
* Environment configuration

금지:

* 하드코딩
* GitHub 직접 업로드
* ViewModel 내부 저장

예시:

```swift
AppConfiguration.apiKey
```

---

# DTO Policy

## DTO Responsibility

DTO는 API 응답 decode 전용 객체다.

예시:

```swift
struct DrugItemDTO: Decodable {
    let itemName: String
    let entpName: String
    let efcyQesitm: String?
}
```

규칙:

* DTO는 Data Layer 내부에만 존재
* DTO를 Domain으로 직접 전달 금지
* API 필드명 유지 허용
* UI 표시용 로직 금지

---

# Entity Mapping Policy

DTO는 Mapper를 통해 Domain Entity로 변환한다.

예시:

```swift
DrugItemDTO
→ DrugMapper
→ Drug
```

규칙:

* Mapper에서 nil 처리
* 화면 표시용 formatting 금지
* Domain 친화적 타입 변환

예시:

```swift
Drug(
    name: dto.itemName,
    company: dto.entpName
)
```

---

# Domain Entity Policy

## Drug Entity

예시:

```swift
struct Drug {
    let name: String
    let company: String
    let efficacy: String?
    let usage: String?
    let warning: String?
}
```

규칙:

* Domain Entity는 순수 Swift 타입 유지
* Alamofire/DTO 의존 금지
* View 상태 포함 금지

---

# Search Policy

## Debounce

검색은 debounce 적용.

기본값:

```text id="y3bajw"
0.3 seconds
```

목적:

* 과도한 API 호출 방지
* UX 안정화

예시:

```swift
.debounce(
    for: .milliseconds(300),
    scheduler: RunLoop.main
)
```

---

# Empty Query Policy

빈 검색어는 API 호출하지 않는다.

규칙:

* trim 후 빈 문자열 검사
* 최소 2자 입력 권장

예시 UX:

```text id="7g5ln2"
약 이름을 입력해주세요
```

---

# Loading Policy

검색 중에는 loading 상태를 표시한다.

예시:

```text id="olrf6i"
검색 중...
```

규칙:

* skeleton 또는 ProgressView 사용 가능
* 중복 loading 상태 최소화
* loading 중 UI freeze 금지

---

# Empty Result Policy

검색 결과 없음은 정상 UX Case다.

예시:

```text id="5n7v8t"
검색 결과가 없어요
직접 입력하기
```

규칙:

* Empty Result를 Error로 처리하지 않는다.
* fallback action 제공
* IVF 약 특성상 직접 입력 가능해야 한다.

---

# Network Error Policy

## Retry

네트워크 오류 시 retry 1회 허용.

흐름:

```text
Request
→ Failure
→ Retry 1
→ Failure
→ Error State
```

규칙:

* 무한 retry 금지
* retry는 자동 1회만 수행

---

## Error UX

예시:

```text id="8nkl3y"
네트워크 오류가 발생했어요
잠시 후 다시 시도해주세요
```

fallback:

```text id="rsy5yv"
직접 입력하기
```

---

# Error Types

## NetworkError

예시:

```swift
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case serverError
    case unknown
}
```

규칙:

* 사용자 표시용 메시지와 내부 error 분리
* Alamofire Error 직접 노출 금지

---

# Async/Await Policy

네트워크 요청은 async/await 사용.

예시:

```swift
func search(keyword: String) async throws -> [Drug]
```

규칙:

* callback 기반 API 사용 금지
* completion handler 신규 작성 금지
* async/await 중심 유지

---

# Combine Integration

SwiftUI Feature에서는 Combine으로 API 상태 관리.

예시:

```swift
@Published var searchText = ""
@Published var drugs: [Drug] = []
```

규칙:

* debounce는 ViewModel에서 처리
* View 내부 API 호출 금지
* API 상태는 ObservableObject로 관리

---

# RxSwift Integration

UIKit Feature에서는 RxSwift 사용.

예시:

```swift
PublishRelay<String>
BehaviorRelay<[Drug]>
```

규칙:

* API 호출은 ViewModel에서 수행
* Driver 기반 UI 바인딩 우선
* DisposeBag lifecycle 명확히 관리

---

# Direct Input Fallback

DrugSearch 결과가 없을 경우 직접 입력 fallback 제공.

흐름:

```text
No Search Result
→ 직접 입력하기
→ MedicationForm
```

자동 입력 실패 시에도 사용자는 약 등록 가능해야 한다.

---

# Offline Policy

MVP 기준:

* 완전 오프라인 검색 미지원
* 네트워크 기반 검색 우선
* 저장된 Medication은 로컬 유지

---

# Rate Limit Policy

e약은요 API는 일일 요청 제한 존재.

규칙:

* debounce 필수
* 빈 검색어 요청 차단
* 불필요한 detail request 금지
* 동일 검색 반복 최소화

---

# Security Policy

금지:

* API Key 하드코딩
* 로그에 개인정보 출력
* 디버그 print 남용

규칙:

* 민감 정보는 configuration 관리
* production logging 최소화

---

# Test Policy

테스트 대상:

* SearchDrugUseCase
* DrugRepository
* Mapper
* Error Handling

필수 테스트:

* 정상 검색
* Empty Query
* Empty Result
* Network Error
* Decoding 실패

Mock 사용:

```text
MockDrugRepository
MockAPIClient
```

---

# Portfolio Principles

이 프로젝트는 포트폴리오 목적의 앱이다.

API 구조에서 중요하게 보는 요소:

* Router 패턴 사용 이유 설명 가능
* DTO / Entity 분리 설명 가능
* async/await 선택 이유 설명 가능
* fallback UX 설명 가능
* retry 정책 설명 가능
* Infrastructure 분리 이유 설명 가능

우선순위:

1. 명확한 흐름
2. 테스트 가능성
3. 유지보수성
4. 사용자 fallback UX
5. 기술 선택 설명 가능성
