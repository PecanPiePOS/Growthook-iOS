//
//  InsightsDetailService.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum InsightsDetailTarget {
    case getAllActionPlans(seedId: Int)
    case editActionPlan(actionPlanId: Int, editedActionPlan: InsightActionPlanPatchRequest)
    case deleteActionPlan(actionPlanId: Int)
    case completeActionPlan(actionPlanId: Int)
    case postReviewToCompleteActionPlan(content: String, actionPlanId: Int)
    case postNewSingleActionPlan(seedId: Int, newActionPlan: InsightAddExtraActionPlanRequest)
    case scrapSeed(seedId: Int)
    case scrapActionPlan(actionPlanId: Int)
    
    case moveSeed(seedId: Int, caveId: Int)
    case getAllCaves(memberId: Int)
    case getSeedDetail(seedId: Int)
}

extension InsightsDetailTarget: BaseTargetType {
    
    var headers: [String : String]? {
        APIConstants.headerWithAuthorization
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var path: String {
        switch self {
        case .getAllActionPlans(let seedId):
            let newPath = URLConstant.actionPlanGet.replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        case .editActionPlan(let actionPlanId, _):
            let newPath = URLConstant.actionPlanEdit.replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .deleteActionPlan(let actionPlanId):
            let newPath = URLConstant.actionPlanDelete.replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .completeActionPlan(let actionPlanId):
            let newPath = URLConstant.actionPlanCompletion.replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .postNewSingleActionPlan(let seedId, _):
            let newPath = URLConstant.actionPlanGet.replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        case .moveSeed(let seedId, _):
            let newPath = URLConstant.seedMove.replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        case .getAllCaves(let memberId):
            let newPath = URLConstant.caveAllGet.replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        case .getSeedDetail(let seedId):
            let newPath = URLConstant.seedDetailGet.replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        case .postReviewToCompleteActionPlan(_, let actionPlanId):
            let newPath = URLConstant.actionPlanReview.replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .scrapSeed(let seedId):
            let newPath = URLConstant.toggleSeedScrapStatus
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return newPath
        case .scrapActionPlan(let actionPlanId):
            let newPath = URLConstant.actionPlanScrap
                .replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        }
    }
        
    var method: Moya.Method {
        switch self {
        case .getAllActionPlans:
            return .get
        case .editActionPlan:
            return .patch
        case .deleteActionPlan:
            return .delete
        case .completeActionPlan:
            return .patch
        case .postNewSingleActionPlan:
            return .post
        case .moveSeed:
            return .post
        case .getAllCaves:
            return .get
        case .getSeedDetail:
            return .get
        case .postReviewToCompleteActionPlan:
            return .post
        case .scrapSeed:
            return .patch
        case .scrapActionPlan:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getAllActionPlans:
            return .requestPlain
        case .editActionPlan(_, let editedActionPlan):
            let editedData = try! editedActionPlan.asParameter()
            return .requestParameters(parameters: editedData, encoding: JSONEncoding.default)
        case .deleteActionPlan:
            return .requestPlain
        case .completeActionPlan:
            return .requestPlain
        case .postNewSingleActionPlan(_, let newActionPlan):
            let newData = try! newActionPlan.asParameter()
            return .requestParameters(parameters: newData, encoding: JSONEncoding.default)
        case .moveSeed(_, let caveId):
            let newCave = ["caveId": caveId]
            return .requestParameters(parameters: newCave, encoding: JSONEncoding.default)
        case .getAllCaves:
            return .requestPlain
        case .getSeedDetail:
            return .requestPlain
        case .postReviewToCompleteActionPlan(let content, _):
            let newReview = ["content": content]
            return .requestParameters(parameters: newReview, encoding: JSONEncoding.default)
        case .scrapSeed:
            return .requestPlain
        case .scrapActionPlan:
            return .requestPlain
        }
    }
}

struct InsightsDetailService: Networkable {
    typealias Target = InsightsDetailTarget
    private static let provider = makeProvider()
    
    static func getAllActionPlans(seedId: Int) -> Observable<[InsightActionPlanResponse]> {
        return provider.rx.request(.getAllActionPlans(seedId: seedId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: [InsightActionPlanResponse].self)
    }
    
    static func editActionPlan(actionPlanId: Int, editedActionPlan: InsightActionPlanPatchRequest, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.editActionPlan(actionPlanId: actionPlanId, editedActionPlan: editedActionPlan)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            editActionPlan(actionPlanId: actionPlanId, editedActionPlan: editedActionPlan, handler: handler)
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
    
    static func editActionPlan(actionPlanId: Int, editedActionPlan: InsightActionPlanPatchRequest) -> Observable<GeneralResponse<InsightSuccessResponse>> {
        return provider.rx.request(.editActionPlan(actionPlanId: actionPlanId, editedActionPlan: editedActionPlan))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: GeneralResponse<InsightSuccessResponse>.self)
    }
    
    static func deleteActionPlan(actionPlanId: Int) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.deleteActionPlan(actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func deleteActionPlan(actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.deleteActionPlan(actionPlanId: actionPlanId)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            deleteActionPlan(actionPlanId: actionPlanId, handler: handler)
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
    
    static func completeActionPlan(actionPlanId: Int) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.completeActionPlan(actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func postSingleNewActionPlan(seedId: Int, newActionPlan: InsightAddExtraActionPlanRequest) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.postNewSingleActionPlan(seedId: seedId, newActionPlan: newActionPlan))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func postSingleNewActionPlan(seedId: Int, newActionPlan: InsightAddExtraActionPlanRequest, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.postNewSingleActionPlan(seedId: seedId, newActionPlan: newActionPlan)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            postSingleNewActionPlan(seedId: seedId, newActionPlan: newActionPlan, handler: handler)
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
    
    static func completeActionPlan(actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.completeActionPlan(actionPlanId: actionPlanId)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            completeActionPlan(actionPlanId: actionPlanId, handler: handler)
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
    
    static func postReview(content: String, actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.postReviewToCompleteActionPlan(content: content, actionPlanId: actionPlanId)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            postReview(content: content, actionPlanId: actionPlanId, handler: handler)
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
    
    static func moveSeed(withSeedOf seedId: Int, to caveId: Int) -> Observable<CaveSuccessResponse> {
        return provider.rx.request(.moveSeed(seedId: seedId, caveId: caveId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: CaveSuccessResponse.self)
    }
    
    static func getAllCaves(memberId: Int) -> Observable<[CaveSuccessResponse]> {
        return provider.rx.request(.getAllCaves(memberId: memberId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: [CaveSuccessResponse].self)
    }
    
    static func getSeedDetail(seedId: Int) -> Observable<SeedDetailResponsse> {
        return provider.rx.request(.getSeedDetail(seedId: seedId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: SeedDetailResponsse.self)
    }
    
    static func postNewReviewToComplete(content: String, actionPlanId: Int) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.postReviewToCompleteActionPlan(content: content, actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func scrapSeed(seedId: Int, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.scrapSeed(seedId: seedId)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            scrapSeed(seedId: seedId, handler: handler)
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
    
    static func scrapActionPlan(actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        provider.request(.scrapActionPlan(actionPlanId: actionPlanId)) { result in
            switch result {
            case .success(let response):
                if response.statusCode < 204 {
                    handler(true)
                } else if response.statusCode == 401 {
                    TokenManager.shared.refreshNewToken { success in
                        if success {
                            scrapActionPlan(actionPlanId: actionPlanId, handler: handler)
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


