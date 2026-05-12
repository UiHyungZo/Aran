import Foundation

enum AppError: Error, LocalizedError {
    case networkError(Error)
    case emptyResult
    case invalidInput(String)
    case storageError(Error)
    case notificationError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError: return "네트워크 오류가 발생했습니다."
        case .emptyResult: return "검색 결과가 없습니다."
        case .invalidInput(let msg): return msg
        case .storageError: return "저장 중 오류가 발생했습니다."
        case .notificationError: return "알림 설정 중 오류가 발생했습니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        }
    }
}
