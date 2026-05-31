import Foundation

protocol DrugApprovalAPIClientProtocol {
    /// primary 검색: 효능·용법·주의사항까지 포함한 풍부한 Drug 반환
    func searchDrugs(itemName: String, pageNo: Int) async throws -> DrugSearchResult
    /// e약은요 fallback 결과 보강용 메타데이터
    func fetchApprovalInfo(itemName: String) async throws -> [DrugApprovalInfo]
}
