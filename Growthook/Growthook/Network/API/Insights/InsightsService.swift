//
//  InsightsService.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum InsightsTarget {
    case postNewInsight(caveId: Int, insightParameter: InsightPostRequest)
}

extension InsightsTarget: BaseTargetType {
    
    var headers: [String : String]? {
        APIConstants.headerWithAuthorization
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var path: String {
        switch self {
        case .postNewInsight(let caveId, _):
            let newPath: String = URLConstant.seedPost
                .replacingOccurrences(of: "{caveId}", with: String(caveId))
            return newPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postNewInsight:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postNewInsight(_, let insightParameter):
            let parameters = try! insightParameter.asParameter()
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
}

struct InsightsService: Networkable {
    typealias Target = InsightsTarget
    private static let provider = makeProvider()
    
    static func postNewInsight(caveId: Int, of insight: InsightPostRequest) -> Observable<InsightPostResponse> {
        return provider.rx.request(.postNewInsight(caveId: caveId, insightParameter: insight))
            .asObservable()
            .mapError()
            .decode(decodeType: InsightPostResponse.self)
    }
    
}
