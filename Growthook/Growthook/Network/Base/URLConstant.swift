//
//  URLConstant.swift
//  Growthook
//
//  Created by KJ on 11/4/23.
//

import Foundation

enum URLConstant {
    
    // MARK: - Base URL
    
    static let baseURL = Config.baseURL
    
    // MARK: - URL Path
    
    // MARK: - ActionPlan
    
    static let actionPlan = "/api/v1/actionPlan/{actionPlanId}"
    static let actionPlanCompletion = "/api/v1/actionPlan/{actionPlanId}/completion"
    static let actionPlanPercent = "/api/v1/member/{memberId}/actionPlan/percent"
    static let doingActionPlan = "/api/v1/member/{memberId}/doing"
    static let finishedActionPlan = "/api/v1/member/{memberId}/doing"
    static let actionPlanGet = "/api/v1/member/{memberId}/doing"
    static let actionPlanPost = "/api/v1/seed/{seedId}/actionPlan"
    
    // MARK: - Cave
    
    static let cave = "/api/v1/cave/{caveId}"
    static let cavePost = "/api/v1/member/{memberId}/cave"
    static let caveDetailGet = "/api/v1/member/{memberId}/cave/{caveId}/detail"
    static let caveAllGet = "/api/v1/member/{memberId}/cave/all"
    
    // MARK: - Insight
    
    static let seedPost = "/api/v1/cave/{caveId}/seed"
    static let seed = "/api/v1/seed/{seedId}"
    static let seedDetailGet = "/api/v1/seed/{seedId}/detail"
    static let seedMove = "/api/v1/seed/{seedId}/move"
    static let seedListByCaveGet = "/api/v1/cave/{caveId}/seed/list"
    static let seedAlarm = "/api/v1/member/{memberId}/alarm"
    static let seedListGet = "/api/v1/member/{memberId}/seed/list"
    static let unLockSeed = "/api/v1/seed/{seedId}/lock/status"
    static let toggleSeedScrapStatus = "/api/v1/seed/{seedId}/scrap/status"
}
