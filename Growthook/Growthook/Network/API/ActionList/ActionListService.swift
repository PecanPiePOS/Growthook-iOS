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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getActionListPercent, .getActionListDoing, .getActionListFinished:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getActionListPercent, .getActionListDoing, .getActionListFinished:
            return .requestPlain
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
            .decode(decodeType: [ActionListFinishedResponse].self)
    }
    
    
}
