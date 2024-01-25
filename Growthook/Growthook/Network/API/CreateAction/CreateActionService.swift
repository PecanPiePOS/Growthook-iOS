//
//  CreateActionService.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/14/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum CreateActionTarget {
    case postActionPlan(seedId: Int, parameter: CreateActionRequest)
    case getSeedDetail(seedId: Int)
}

extension CreateActionTarget: BaseTargetType {
    
    var headers: [String : String]? {
        APIConstants.headerWithAuthorization
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var path: String {
        switch self {
        case .postActionPlan(let seedId, _):
            let newPath = URLConstant.actionPlanPost
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        case .getSeedDetail(let seedId):
            let newPath = URLConstant.seedDetailGet
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postActionPlan:
            return .post
        case .getSeedDetail:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postActionPlan(_, let parameter):
            let parameters = try! parameter.asParameter()
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getSeedDetail(_):
            return .requestPlain
        }
    }
}

struct CreateActionService: Networkable {
    typealias Target = CreateActionTarget
    private static let provider = makeProvider()

    static func postActionPlan(seedId: Int, actionPlan: CreateActionRequest) -> Observable<CreateActionResponse> {
        return provider.rx.request(.postActionPlan(seedId: seedId, parameter: actionPlan))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: CreateActionResponse.self)
    }
    
    static func getSeedDetail(seedId: Int) -> Observable<ActionPlanResponse> {
        return provider.rx.request(.getSeedDetail(seedId: seedId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: ActionPlanResponse.self)
    }
}

struct CreateActionRequest: Codable {
    var contents: [String]
}

struct CreateActionResponse: Codable {
}

struct ActionPlanResponse: Codable {
    let caveName: String
    let insight: String
    let memo: String
    let source: String
    let url: String
    let isScraped: Bool
    let lockDate: String
    let remainingDays: Int
}
