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
    case editInsight(seedId: Int, insightParameter: InsightEditRequest)
    case deleteInsight(seedId: Int)
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
        case .editInsight(let seedId, _):
            let newPath: String = URLConstant.seed
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        case .deleteInsight(let seedId):
            let newPath = URLConstant.seed.replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        }
    }
        
    var method: Moya.Method {
        switch self {
        case .postNewInsight:
            return .post
        case .editInsight:
            return .patch
        case .deleteInsight:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postNewInsight(_, let insightParameter):
            let parameters = try! insightParameter.asParameter()
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .editInsight(_, let insightParameter):
            let parameters = try! insightParameter.asParameter()
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .deleteInsight:
            return .requestPlain
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
            .retryOnTokenExpired()
            .decode(decodeType: InsightPostResponse.self)
    }
    
    static func editInsight(seedId: Int, of insight: InsightEditRequest) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.editInsight(seedId: seedId, insightParameter: insight))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func deleteInsight(seedId: Int) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.deleteInsight(seedId: seedId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func deleteInsight(seedId: Int, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.deleteInsight(seedId: seedId)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            deleteInsight(seedId: seedId, handler: handler)
                        } else {
                            handler(false)
                        }
                    }
                } else {
                    handler(false)
                }
            case .failure(let error):
                print(error, "📌")
                handler(false)
            }
        }
    }
}
