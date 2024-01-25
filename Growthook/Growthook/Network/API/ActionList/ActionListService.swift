//
//  ActionListService.swift
//  Growthook
//
//  Created by 천성우 on 1/7/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum ActionListTarget {
    case getActionListPercent(memberId: Int)
    case getActionListDoing(memberId: Int)
    case getActionListFinished(memberId: Int)
    case patchActionListCompletion(actionPlanId: Int)
    case getActionListReview(actionPlanId: Int)
    case postActionListReview(actionPlanId: Int, parameter: ActionListReviewPostRequest)
    case patchACtionListScrap(actionPlanId: Int)
}

extension ActionListTarget: BaseTargetType {
    
    var headers: [String : String]? {
        APIConstants.headerWithAuthorization
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var path: String {
        switch self {
        case .getActionListPercent(let memberId):
            let newPath = URLConstant.actionPlanPercent
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        case .getActionListDoing(let memberId):
            let newPath = URLConstant.doingActionPlan
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        case .getActionListFinished(let memberId):
            let newPath = URLConstant.finishedActionPlan
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        case .patchActionListCompletion(let actionPlanId):
            let newPath = URLConstant.actionPlanCompletion
                .replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .getActionListReview(let actionPlanId):
            let newPath = URLConstant.review
                .replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .postActionListReview(let actionPlanId, _):
            let newPath = URLConstant.review
                .replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        case .patchACtionListScrap(let actionPlanId):
            let newPath = URLConstant.actionPlanScrap
                .replacingOccurrences(of: "{actionPlanId}", with: String(actionPlanId))
            return newPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getActionListPercent, .getActionListDoing, .getActionListFinished, .getActionListReview:
            return .get
        case .patchActionListCompletion, .patchACtionListScrap:
            return .patch
        case .postActionListReview:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getActionListPercent, .getActionListDoing, .getActionListFinished, .patchActionListCompletion, .patchACtionListScrap, .getActionListReview:
            return .requestPlain
        case .postActionListReview(_, let parameter):
            let parameters = try! parameter.asParameter()
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
}


struct ActionListService: Networkable {
    typealias Target = ActionListTarget
    private static let provider = makeProvider()
    
    /**
     액션리스트 진행도를 호출합니다
     - parameter memberId: Int
     */
    
    static func getActionListPercent(with memberId: Int) -> Observable<Int> {
        return provider.rx.request(.getActionListPercent(memberId: memberId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: Int.self)
    }
    
    /**
     진행중인 액션리스트 정보를 호출합니다
     - parameter memberId: Int
     */
    
    static func getDoingActionList(with memberId: Int) -> Observable<[ActionListDoingResponse]> {
        return provider.rx.request(.getActionListDoing(memberId: memberId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: [ActionListDoingResponse].self)
    }
    
    /**
     완료한 액션리스트 정보를 호출합니다
     - parameter memberId: Int
     */
    
    static func getFinishedActionList(with memberId: Int) -> Observable<[ActionListFinishedResponse]> {
        return provider.rx.request(.getActionListFinished(memberId: memberId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: [ActionListFinishedResponse].self)
    }
    
    /**
     액션리스트의 상태를 완료로 변경합니다
     - parameter actionPlanId: Int
     */
    
    static func patchActionListCompletion(with actionPlanId: Int) -> Observable<ActionListCompletionResponse> {
        return provider.rx.request(.patchActionListCompletion(actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: ActionListCompletionResponse.self)
    }
    
    
    /**
     액션리스트의 리뷰 정보를 호출합니다
     - parameter actionPlanId: Int
     */
    
    static func getActionListReview(with actionPlanId: Int) -> Observable<ActionListReviewDetailResponse> {
        return provider.rx.request(.getActionListReview(actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: ActionListReviewDetailResponse.self)
    }
    
    /**
     액션리스트의 리뷰를 작성합니다
     - parameter actionPlanId: Int
     */
    
    static func postActionListReview(actionPlanId: Int, review: ActionListReviewPostRequest) -> Observable<ActionListReviewPostResponse> {
        return provider.rx.request(.postActionListReview(actionPlanId: actionPlanId, parameter: review))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: ActionListReviewPostResponse.self)
    }
    
    /**
     액션리스트를 스크랩 합니다
     - parameter actionPlanId: Int
     */
    
    static func patchACtionListScrap(with actionPlanId: Int) -> Observable<ActionListScrapResponse> {
        return provider.rx.request(.patchACtionListScrap(actionPlanId: actionPlanId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: ActionListScrapResponse.self)
    }
    
}
