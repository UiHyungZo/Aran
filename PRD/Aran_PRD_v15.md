**🌸 PRD: Aran v15.0**

Product Requirements Document

*IVF 치료 흐름 통합 관리 iOS 앱*

| 항목 | 내용 |
| :---- | :---- |
| 버전 | v15.0 |
| 작성일 | 2026-06-04 |
| 플랫폼 | iOS 17+ |
| 언어 | Swift 6 |
| 아키텍처 | Clean Architecture \+ MVVM |
| 상태 | 완료 |
| 기획기간 | 26.5.6 \~ 26.5.12 |
| 개발기간 | 26.5.13 \~ 26.6.3 |

# **1\. 프로젝트 목표**

Aran은 시험관 시술(IVF) 치료 흐름을 관리하는 iOS 포트폴리오 앱이다.  
사용자가 치료 일정, 약물/주사 기록, 검사 수치, 배아이식/채취 기록, 의약품 정보를 하나의 캘린더 중심 구조로 통합 관리할 수 있게 한다.

* IVF 치료 흐름을 캘린더 중심으로 통합  
* 약물/주사 복용 추적 및 알림 관리  
* 검사 수치 기록 및 트렌드 시각화  
* 차수별 채취/이식/PGT 이력 관리  
* 식약처 API 기반 의약품 정보 검색

# **2\. 앱 구조 — 5탭**

| 탭 | 기술 스택 | 역할 |
| :---- | :---- | :---- |
| 📅 캘린더 | SwiftUI \+ Combine | 날짜 기반 모든 정보의 허브. 2단계 바텀시트 구조 |
| 💊 약/주사 | UIKit \+ RxSwift | 복용 약 관리, 알림 설정, 약 검색 register 모드 |
| 🏥 검사 | UIKit \+ RxSwift \+ Swift Charts | 혈액/초음파 수치 입력, 항목별 목록, 트렌드 차트 |
| 🗂 시술 기록 | SwiftUI \+ Combine \+ Swift Charts | 차수별 채취/이식/PGT 이력 관리 및 차트 |
| 🔍 약 정보 | SwiftUI \+ Combine | 식약처 API 약 검색 browse 모드, 즐겨찾기, 상세 정보 |

# **3\. 캘린더 탭 — 2단계 바텀시트 구조**

| 단계 | 화면 | 설명 |
| :---- | :---- | :---- |
| 0단계 | 캘린더 메인 | 월간 달력. 날짜별 도트 표시. 날짜 탭 시 1단계 시트 |
| 1단계 | 날짜 요약 시트 | 해당 주 7일 \+ 선택 날짜 모든 기록 요약. 항목 탭 시 2단계 시트 |
| 2단계 | 항목별 입력/수정 시트 | 실제 데이터 입력 및 수정/삭제.  |

## **3.1 캘린더 도트 종류**

| 타입 | 색상(Light mode) | 색상(Dark mode) | 표시 형태 |
| :---- | :---- | :---- | :---- |
| 병원 일정 | Pink(\#D4688A) | Pink(\#E88FAB) | 채워진 원 |
| 이식일 | Green(\#1D9E75) | Green(\#479191) | 채워진 원 |
| 약 복용 알림 | Purple(\#534AB7) | Purple(\#9488DC) | 채워진 원 |
| 검사 | Blue(\#185FA5) | Blue(\#6FB6F2) | 채워진 원 |
| 생리 기간 | Pink(\#D4688A) | Pink(\#E88FAB) | 채워진 원 |
| 배란일 | Amber(\#BA7517) | Amber(\#D49029) | 채워진 원 |
| 일기 | Red(\#D94F4F) | Red(\#F08080) | 채워진 원 |

## **3.2 1단계 시트 섹션**

| 섹션 | 기록 있을 때 | 기록 없을 때 | 탭 시 동작 |
| :---- | :---- | :---- | :---- |
| 병원 일정 | 일정 종류(복수) \+ 메모 | 일정 없음 | 2단계: 병원 일정 입력/수정 시트 |
| 복용 약 | 약 이름 pill \+ 체크박스 | 복용 약 없음 | 체크 토글 (복용 완료). 약 추가는 약/주사 탭 |
| 감정 일기 | 이모지 \+ 텍스트 미리보기 | 기록 없음 | 2단계: 감정 일기 입력/수정 시트 |
| 검사 수치 | 항목·수치 요약 | 기록 없음 | 2단계: 검사 수치 입력/수정 시트 |
| 생리 시작일 | 생리 시작일로 표시 | 오늘로 기록하기 버튼 | 2단계: 생리 주기 입력/수정 시트 |

## **3.3 2단계 시트 입력 내용**

| 시트 | 입력 내용 | 수정/삭제 |
| :---- | :---- | :---- |
| 병원 일정 | 날짜(자동) · 일정 종류 복수 선택(내원/채혈/초음파) · 메모 | 수정 가능 · 삭제 가능 |
| 감정 일기 | 이모지 선택 · 텍스트 입력(최대 500자) | 수정 가능 · 삭제 가능 |
| 검사 수치 | 항목 선택 · 수치 · 단위 · 측정일 · 메모 | 수정 가능 · 삭제 가능 |
| 생리 주기 | 생리 시작일(자동) · 주기 길이(기본 28일) → 배란 예정일 자동 계산 | 수정 가능 · 삭제 가능 |

# **4\. 핵심 기능 (탭별)**

## **TAB 1 · 📅 캘린더**

* 월간 달력 뷰 — 날짜별 색상 도트, 월 이동  
* 날짜 탭 → 1단계 요약 시트  
* 병원 일정 / 감정 일기 / 검사 수치 / 생리 주기 2단계 입력/수정 시트  
* 1단계 시트 복용 약 체크박스 (MedicationLog SwiftData 저장)  
* 생리 기간 색상 커스터마이징 (Assets: dotHospital / dotPeriod / dotPeriodPredicted)

## **TAB 2 · 💊 약/주사**

* 약 목록 — UITableView, 복용 시간, 체크 상태  
* 약 셀 탭 → 수정 화면 (MedicationFormActions 패턴)  
* 스와이프 액션 — 중단/삭제  
* 약 등록 폼 — DrugSearch register 모드로 자동 입력, 직접 입력 fallback  
* UserNotifications 알림 — 등록/수정/삭제/ON/OFF (MedicationSchedule 단위 관리)  
* 알림 미리보기 — 개별 ON/OFF

## **TAB 3 · 🏥 검사**

* 수치 입력 폼 — 항목 선택 \+ 수치 \+ 단위 \+ 날짜 \+ 메모  
* 검사 항목: 기본 7개 고정(FSH·AMH·AFC·E2·P4·LH·β-hCG) \+ 직접 추가 가능  
* 수치 목록 — 항목별 최신 수치 \+ 증감 TrendBadge (↑↓)  
* 수치 히스토리 — 항목별 시간순 목록  
* Swift Charts Line Chart — 수치 변화, 정상 범위 레퍼런스 라인

## **TAB 4 · 🗂 시술 기록**

* 차수 목록 — 차수별 카드(채취/수정/동결 개수, 이식 결과 요약, 진행중/성공/실패 배지)  
* 차수 상세 화면 — 채취→수정→동결→이식→PGT 결과 한눈에  
* 채취/이식 입력 — 차수·개수·등급·동결/신선  
* 이식 결과 기록 — 이식일·등급·개수·결과(성공/실패/진행중)  
* PGT / 염색체 / 반착검사 기록  
* Swift Charts Bar Chart — 차수별 채취→수정→동결→이식 흐름

## **TAB 5 · 🔍 약 정보**

* 약 이름 검색 — Combine .debounce(0.3s) → e약은요 API  
* 전문의약품 폴백 — DrugApprovalAPIClient (e약은요 fallback)  
* 검색 결과 목록 및 약 상세 정보 (효능/용법/주의사항/경고 배너)  
* 약 추가 연동 — 이 약 추가하기 → MedicationFormVC  
* 즐겨찾기 — FavoriteDrug 전체 스택 (Domain/Data/Repository/UseCase/View)  
* 최근 검색어 — SwiftData 기반 저장/표시

# **5\. 검사 탭 — 항목 정의**

## **5.1 기본 제공 항목 (7개)**

| 항목 | 단위 | 카테고리 |
| :---- | :---- | :---- |
| FSH | mIU/mL | 난소 기능 검사 |
| AMH | ng/mL | 난소 기능 검사 |
| AFC | 개 | 난소 기능 검사 |
| E2 | pg/mL | 호르몬 검사 |
| P4 | ng/mL | 호르몬 검사 |
| LH | mIU/mL | 호르몬 검사 |
| β-hCG | mIU/mL | 임신 확인 |

## **5.2 커스텀 항목**

* 기본 7개 외 항목은 사용자가 직접 이름·단위 입력하여 추가 가능  
* HealthRecord.type 필드에 String으로 저장  
* 커스텀 항목도 동일하게 수치 입력·히스토리·차트 지원

# **6\. 외부 API**

6.1 의약품허가정보서비스 (Primary)

| 항목 | 내용 |
| :---- | :---- |
| 서비스명 | 의약품허가정보서비스 (DrugPrdtPrmsnInfoService07)  |
| Base URL | https://apis.data.go.kr/1471000/DrugPrdtPrmsnInfoService07 |
| 역할 | 전문의약품 우선 검색 |

| 항목 | 내용 |
| :---- | :---- |
| 엔드포인트 | getDrugPrdtPrmsnInq07 |
| 용도 | 약 이름 검색 (Primary) |
| 주요 파라미터 | item\_name, pageNo, numOfRows=20 |
| 응답 필드 | ITEM\_SEQ, ITEM\_NAME, ENTP\_NAME, ETC\_OTC\_CODE, EE\_DOC\_DATA(XML), UD\_DOC\_DATA(XML), NB\_DOC\_DATA(XML), MAIN\_ITEM\_INGR, EDI\_CODE, ATC\_CODE |
| 특이사항 | XML 필드(EE\_DOC\_DATA 등)는 DocDataXMLParser로 파싱 필요 |

| 항목 | 내용 |
| :---- | :---- |
| 엔드포인트 | getDrugPrdtPrmsnDtlInq06 |
| 용도 | 목록 응답에 효능·용법 정보가 비어있을 때 보강 |
| 주요 파라미터 | item\_seq, pageNo=1, numOfRows=1 |
| 호출 조건 | efcyQesitm 또는 useMethodQesitm 이 비어있는 경우 |
| 비고 | needsDetailEnrichment 로직 사용 |

6.2 e약은요 OpenAPI (Fallback)

| 항목 | 내용 |
| :---- | :---- |
| 서비스명 | 의약품개요정보 (e약은요) OpenAPI |
| 출처 | 식품의약품안전처 |
| Base URL | https://apis.data.go.kr/1471000/DrbEasyDrugInfoService |
| 역할 | Primary 검색 실패 시 Fallback |
| 요금 | 무료 (개발계정 일 10,000건) |

| 항목 | 내용 |
| :---- | :---- |
| 엔드포인트 | getDrbEasyDrugList |
| 용도 | 약 이름 검색 (Fallback) |
| 주요 파라미터 | itemName, pageNo, numOfRows=20, type=json |
| 응답 필드 | itemSeq, itemName, entpName, efcyQesitm, useMethodQesitm, atpnWarnQesitm, atpnQesitm, seQesitm, depositMethodQesitm, itemImage |
| 특이사항 | 검색 응답에 상세 정보 포함 → 별도 Detail API 호출 불필요 |

6.3 검색 흐름 요약

| 순서 | API | 동작 |
| :---- | :---- | :---- |
| 1 | 의약품허가정보서비스 | 약품명 검색 |
| 2 | 결과 존재 | 결과 반환 |
| 3 | 효능·용법 누락 | getDrugPrdtPrmsnDtlInq06 호출 |
| 4 | 결과 없음 | e약은요 OpenAPI 호출 |
| 5 | e약은요 결과 존재 | 결과 반환 |
| 6 | 둘 다 없음 | 검색 실패 처리 |

# **7\. 핵심 데이터 모델**

| Entity | 목적 | 관계 |
| :---- | :---- | :---- |
| CycleRecord | IVF 차수별 채취/수정/동결 기록 | 1:N → TransferRecord, PGTRecord |
| TransferRecord | 배아이식 상세 기록 | N:1 → CycleRecord |
| PGTRecord | PGT/염색체/반착검사 결과 | N:1 → CycleRecord |
| Medication | 복용 약 및 주사 | 1:N → MedicationSchedule, MedicationLog |
| MedicationSchedule | 복용 시간 및 알림 관리 | N:1 → Medication |
| MedicationLog | 날짜별 복용 완료 체크 기록  | N:1 → Medication   |
| HealthRecord | 검사 수치 (기본 7개 \+ 커스텀) | \- |
| DiaryEntry | 감정 기록 | \- |
| HospitalVisit | 병원 일정 (복수 종류 지원) | \- |
| MenstrualCycle | 생리 주기 및 배란 예정일 | \- |
| Drug / FavoriteDrug | 외부 API 약 정보 및 즐겨찾기 | \- |
| RecentDrugSearch | 최근 검색어 | \- |

# **8\. 아키텍처 정책**

## **8.1 레이어 구조**

* Presentation Layer — SwiftUI+Combine / UIKit+RxSwift (탭별 고정)  
* Domain Layer — UseCase, Entity, Repository Protocol (순수 Swift, 프레임워크 의존 없음)  
* Data Layer — SwiftData, Alamofire, UserNotifications, Mapper

## **8.2 의존성 방향**

* Presentation → Domain ← Data (단방향)  
* SwiftData Model → Mapper → Domain Entity (직접 전달 금지)  
* DIContainer Scene 단위 분리 (CalendarScene / Medication / HealthRecord / DrugInfo / ProcedureRecord)

## **8.3 탭별 UI 스택**

| 탭 | UI 스택 | 이유 |
| :---- | :---- | :---- |
| 캘린더 | SwiftUI \+ Combine | 복잡한 바텀시트 상태 관리, SwiftUI의 선언형 UI 적합 |
| 약/주사 | UIKit \+ RxSwift | UITableView 기반 목록 \+ 복잡한 알림 로직 |
| 검사 | UIKit \+ RxSwift \+ Swift Charts | UITableView \+ 차트 혼용 |
| 시술 기록 | SwiftUI \+ Combine \+ Swift Charts | 복잡한 차수 상태 관리 |
| 약 정보 | SwiftUI \+ Combine | 검색 debounce \+ 상태 바인딩 |

## **8.4 SwiftUI ↔ UIKit 브릿징**

* UIHostingController — SwiftUI 뷰를 UIKit 컨텍스트에 삽입  
* UIViewControllerRepresentable — UIKit VC를 SwiftUI에 노출  
* MedicationListWrapper / MedicationFormSheet / ExamListWrapper

# **9\. 테스트 전략**

## **9.1 테스트 현황**

| 레이어 | 대상 | 상태 |
| :---- | :---- | :---- |
| UseCase | Medication, HealthRecord, CycleRecord, SearchDrug, MedicationNotification, TransferRecord, FavoriteDrug, MedicationLog, MenstrualCycle, PGTRecord, DiaryEntry, HospitalVisit, RecentDrugSearch | ✅ 완료 |
| ViewModel | CalendarViewModel, DrugInfoViewModel, ExamHistoryViewModel, HealthRecordFormViewModel, HealthRecordViewModel, MedicationViewModel, ProcedureRecordViewModel, MedicationFormViewModel | ✅ 완료 |
| Repository | CycleRecord, TransferRecord, FavoriteDrug, DiaryEntry, Drug, HealthRecord, HospitalVisit, MedicationLog, Medication, MenstrualCycle,  PGTRecord, RecentDrugSearch  | ✅ 완료 |
| Network | DrugRouter, DrugApprovalRouter, DrugAPIClient, DocDataXMLParser | ✅ 완료 |
| Mapper | DrugMapper, DrugApprovalMapper, CycleRecord, DiaryEntry, FavoriteDrug, HealthRecord, HospitalVisit, MedicationLog, Medication, MenstrualCycle, PGTRecord, RecentDrugSearch, TransferRecord  | ✅ 완료 |
| UI Test | 캘린더 / 약 등록 / 약 검색 / 채취·이식 / 검사 수치 플로우, 탭 네비게이션 | ✅ 완료 |

## **9.2 테스트 정책**

*  *비즈니스 로직은 UseCase 단위로 분리하고 MockRepository 기반으로 테스트*  
*  *Mock 객체는 AranTests/Mocks/ 하위에 관리*  
*  *Domain Entity는 순수 Swift 타입 유지 → 테스트 시 프레임워크 불필요*  
*  *테스트 구조: given / when / then*  
*  *테스트명 패턴: test\_기능\_when상황\_then결과*  
*  *하나의 테스트는 하나의 동작만 검증*  
*  *실제 네트워크 / 알림 / SwiftData 의존 금지 (in-memory container 사용)*




# **10\. MVP 제외 사항 (Non-Goals)**

* HealthKit 연동  
* Firebase / Cloud Sync  
* 소셜 로그인  
* iPad 대응  
* Bluetooth  
* 병원 EMR 연동  
* 실사용 의료 진단/처방 기능  
* Widget / Siri Shortcut

# **11\. 성공 기준**

* 주요 기능이 Clean Architecture 기준으로 설명 가능해야 한다  
* UIKit/RxSwift 기능과 SwiftUI/Combine 기능의 경계가 명확해야 한다  
* 면접에서 데이터 흐름, 의존성 방향, 테스트 전략을 설명할 수 있어야 한다  
* UseCase / Repository / ViewModel / UI 전 레이어 테스트가 존재해야 한다  
* 다크모드가 완전 대응되어야 한다

# **12\. 다음 작업 우선순위**

| 순위 | 작업 | 상세 |
| :---- | :---- | :---- |
| 1 | UI Test 작성 | 캘린더 / 약 등록 / 약 검색 / 채취·이식 / 검사 수치 플로우 |
| 2 | 다크모드 완성 | 커스텀 컬러 Assets Light/Dark 두 벌 정의, Swift Charts 다크모드 색상 |
| 3 | 앱 아이콘 | 1024×1024 마스터 에셋, Xcode AppIcon 슬롯 전체 |
| 4 | 스플래시 | LaunchScreen.storyboard 앱 아이콘 중앙 배치 |
| 5 | 배포 준비 | 개인정보처리방침, 앱 메타데이터, 스크린샷 5장, TestFlight 제출 |

# **13\. 버전 변경 이력**

| 버전 | 주요 변경 사항 |
| :---- | :---- |
| v15.0 (현재) | 코드 기반 PRD 재작성. 즐겨찾기/전문의약품 API/캘린더 검사 detail/감정일기 전체 sheet 완성 내용 반영. 테스트 현황 전면 업데이트. 알려진 이슈 추가. |
| v14.1 | 전체 화면 키보드 Dismiss UX 개선 (UIKit \+ SwiftUI 8개 파일) |
| v14.0 | 복용 약 체크 캘린더 연동(MedicationLog), 병원 일정 복수 종류, 수정/삭제 2단계 시트, 차수 상세 화면, 이식 결과 별도 입력, PGT 탭 완전 이동, HealthRecord.type String 전환 |

*Aran · IVF Care iOS App · 2026*