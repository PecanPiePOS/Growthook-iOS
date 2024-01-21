//
//  CaveTarget.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum CaveTarget {
    case getCaveAll(memberId: Int)
    case getCaveDetail(memberId: Int, caveId: Int)
    case patchCave(caveId: Int, param: CavePatchRequestDto)
    case deleteCave(caveId: Int)
}

extension CaveTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .getCaveAll(memberId: let memberId):
            let path = URLConstant.caveAllGet
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return path
        case .getCaveDetail(memberId: let memberId, caveId: let caveId):
            let path = URLConstant.caveDetailGet
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
                .replacingOccurrences(of: "{caveId}", with: String(caveId))
            return path
        case .patchCave(caveId: let caveId, param: _):
            let path = URLConstant.cave
                .replacingOccurrences(of: "{caveId}", with: String(caveId))
            return path
        case .deleteCave(caveId: let caveId):
            let path = URLConstant.cave
                .replacingOccurrences(of: "{caveId}", with: String(caveId))
            return path
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCaveAll, .getCaveDetail:
            return .get
        case .patchCave:
            return .patch
        case .deleteCave:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .patchCave(_, let param):
            return .requestParameters(parameters: try! param.asParameter(), encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return APIConstants.headerWithAuthorization
    }
}
