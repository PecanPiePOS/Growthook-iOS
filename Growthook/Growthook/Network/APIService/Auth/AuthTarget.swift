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
}

extension AuthTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .login:
            return URLConstant.socialLogin
        case .tokenRefresh:
            return URLConstant.tokenRefresh
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .tokenRefresh:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let param):
            return .requestParameters(parameters: try! param.asParameter(), encoding: JSONEncoding.default)
        case .tokenRefresh:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .login(_):
            return APIConstants.headerWithDeviceToken
        case .tokenRefresh:
            return APIConstants.headerWithRefresh
        }
    }
}
