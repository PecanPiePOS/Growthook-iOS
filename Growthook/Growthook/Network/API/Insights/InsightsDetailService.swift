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

/*
 Controller 에
 선행 Data 가 있어야 함 - 액션 플렌이 있는지 없는지
 -> Protocol 을 사용해서 하나로 퉁쳐 만들어.
 -> 있으면 민주꺼 View -> 근데 수정 가능한지?
 -> 없으면 새로 만든 View
 
 */


/*
 
1. /api/v1/seed/{seedId}/actionplan - all 액션플랜 조회 (GET)
2. /api/v1/actionplan/{actionPlanId} - 액션플랜 수정 (PATCH)
3. /api/v1/actionplan/{actionPlanId} - 액션플랜 삭제 (Delete)
4. /api/v1/actionplan/{actionPlanId}/completion - 액션 플랜 완성 (PATCH)
5. /api/v1/seed/{seedId}/actionplan - 액션 플랜 생성 (POST)
 
 */

enum InsightsDetailTarget {
    case getAllActionPlans(seedId: Int)
    case editActionPlan(actionPlanId: Int, editedActionPlan: InsightActionPlanPatchRequest)
    case deleteActionPlan(actionPlanId: Int)
    case completeActionPlan(actionPlanId: Int)
    case postReviewToCompleteActionPlan(content: String, actionPlanId: Int)
    case postNewSingleActionPlan(seedId: Int, newActionPlan: InsightAddExtraActionPlanRequest)
    
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
            let newPath = URLConstant.actionPlanGet.replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .deleteActionPlan(let actionPlanId):
            let newPath = URLConstant.actionPlanGet.replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
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
        case .moveSeed(seedId: let seedId, caveId: let caveId):
            let newCave = ["caveId": caveId]
            return .requestParameters(parameters: newCave, encoding: JSONEncoding.default)
        case .getAllCaves:
            return .requestPlain
        case .getSeedDetail:
            return .requestPlain
        case .postReviewToCompleteActionPlan(let content, _):
            let newReview = ["content": content]
            return .requestParameters(parameters: newReview, encoding: JSONEncoding.default)
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
            .decode(decodeType: [InsightActionPlanResponse].self)
    }
    
    static func editActionPlan(actionPlanId: Int, editedActionPlan: InsightActionPlanPatchRequest) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.editActionPlan(actionPlanId: actionPlanId, editedActionPlan: editedActionPlan))
            .asObservable()
            .mapError()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func deleteActionPlan(actionPlanId: Int) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.deleteActionPlan(actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func completeActionPlan(actionPlanId: Int) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.completeActionPlan(actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func postSingleNewActionPlan(seedId: Int, newActionPlan: InsightAddExtraActionPlanRequest) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.postNewSingleActionPlan(seedId: seedId, newActionPlan: newActionPlan))
            .asObservable()
            .mapError()
            .decode(decodeType: InsightSuccessResponse.self)
    }
    
    static func moveSeed(withSeedOf seedId: Int, to caveId: Int) -> Observable<CaveSuccessResponse> {
        return provider.rx.request(.moveSeed(seedId: seedId, caveId: caveId))
            .asObservable()
            .mapError()
            .decode(decodeType: CaveSuccessResponse.self)
    }
    
    static func getAllCaves(memberId: Int) -> Observable<[CaveSuccessResponse]> {
        return provider.rx.request(.getAllCaves(memberId: memberId))
            .asObservable()
            .mapError()
            .decode(decodeType: [CaveSuccessResponse].self)
    }
    
    static func getSeedDetail(seedId: Int) -> Observable<SeedDetailResponsse> {
        return provider.rx.request(.getSeedDetail(seedId: seedId))
            .asObservable()
            .mapError()
            .decode(decodeType: SeedDetailResponsse.self)
    }
    
    static func postNewReviewToComplete(content: String, actionPlanId: Int) -> Observable<InsightSuccessResponse> {
        return provider.rx.request(.postReviewToCompleteActionPlan(content: content, actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .decode(decodeType: InsightSuccessResponse.self)
    }
}


