import Foundation

protocol DrugApprovalAPIClientProtocol {
    func fetchApprovalInfo(itemName: String) async throws -> [DrugApprovalInfo]
}
