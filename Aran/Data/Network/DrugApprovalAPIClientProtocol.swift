import Foundation

protocol DrugApprovalAPIClientProtocol {
    /// primary 검색: 효능·용법·주의사항까지 포함한 풍부한 Drug 반환
    func searchDrugs(itemName: String, pageNo: Int) async throws -> DrugSearchResult
    /// item_seq 단건 조회: 검색 응답에 본문이 부족한 전문의약품 상세 보강용
    func fetchDetail(itemSeq: String) async throws -> Drug?
}
