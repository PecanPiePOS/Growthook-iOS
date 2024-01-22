//
//  SsukTarget.swift
//  Growthook
//
//  Created by KJ on 1/12/24.
//

import Foundation

import Moya

enum SsukTarget {
    case getSsuk(memberId: Int)
    case getUsedSsuk(memberId: Int)
}

extension SsukTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .getSsuk(memberId: let memberId):
            let path = URLConstant.gatheredSsuk
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return path
        case .getUsedSsuk(memberId: let memberId):
            let path = URLConstant.usedSsuk
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return path
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSsuk, .getUsedSsuk:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return APIConstants.headerWithAuthorization
    }
}

