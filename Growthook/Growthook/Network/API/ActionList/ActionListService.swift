//
//  ActionListService.swift
//  Growthook
//
//  Created by 천성우 on 1/7/24.
//

import Foundation
import Moya

enum ActionListService {
    case getActionListPercent(memberID: String)
}

extension ActionListService: TargetType {
    
    var baseURL: URL {
        return URL(string: URLConstant.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getActionListPercent(let memberID):
            return URLConstant.actionPlanPercent.replacingOccurrences(of: "{memberId}", with: "\(memberID)")
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getActionListPercent:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getActionListPercent:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getActionListPercent:
            return APIConstants.headerWithAuthorization
        }
    }
}
