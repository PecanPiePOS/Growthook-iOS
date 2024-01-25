//
//  ServiceError.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/2/24.
//

import Foundation

import Moya

enum ServiceError: Error {
    case moyaError(MoyaError)
    case invalidResponse(responseCode: Int, message: String)
    case decodingError
    case tokenExpired
    case refreshTokenExpired
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .moyaError(let moyaError):
            return "❗️" + moyaError.localizedDescription + "❗️"
        case .invalidResponse(_, let message):
            return "❗️" + message + "❗️"
        case .tokenExpired:
            return "❗️Access Token Expired❗️"
        case .refreshTokenExpired:
            return "❗️Refresh Token Expired❗️"
        case .decodingError:
            return "❗️Decoding Error Occured❗️"
        }
    }
}

extension ServiceError: Equatable {
    static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.moyaError, .moyaError):
            // MoyaError 비교는 여기서 구현합니다.
            // 예시로, 모든 MoyaError를 동일하게 취급하고 있습니다.
            return true
        case (.invalidResponse(let lhsCode, let lhsMessage), .invalidResponse(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        case (.decodingError, .decodingError),
             (.tokenExpired, .tokenExpired),
             (.refreshTokenExpired, .refreshTokenExpired):
            return true
        default:
            return false
        }
    }
}
