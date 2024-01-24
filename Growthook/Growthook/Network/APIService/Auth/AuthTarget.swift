//
//  AuthTarget.swift
//  Growthook
//
//  Created by KJ on 1/18/24.
//

import Foundation

import Moya

enum AuthTarget {
    case login(param: LoginRequestDto)
    case tokenRefresh
    case withdraw(memberId: Int)
}

extension AuthTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .login:
            return URLConstant.socialLogin
        case .tokenRefresh:
            return URLConstant.tokenRefresh
        case .withdraw(memberId: let memberId):
            let path = URLConstant.memberWithdraw.replacingOccurrences(of: "{memberId}", with: String(memberId))
            return path
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .tokenRefresh:
            return .get
        case .withdraw:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let param):
            return .requestParameters(parameters: try! param.asParameter(), encoding: JSONEncoding.default)
        case .tokenRefresh:
            return .requestPlain
        case .withdraw:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .login(_):
            return APIConstants.headerWithOutToken
        case .tokenRefresh:
            return APIConstants.headerWithRefresh
        case .withdraw:
            return APIConstants.headerWithAuthorization
        }
    }
}
