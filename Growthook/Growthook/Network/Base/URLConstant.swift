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
    
    static let actionPlanDelete = "/api/v1/actionplan/{actionPlanId}"
    static let actionPlanCompletion = "/api/v1/actionplan/{actionPlanId}/completion"
    static let actionPlanPercent = "/api/v1/member/{memberId}/actionplan/percent"
    static let doingActionPlan = "/api/v1/member/{memberId}/doing"
    static let finishedActionPlan = "/api/v1/member/{memberId}/finished"
    static let actionPlanGet = "/api/v1/seed/{seedId}/actionplan"
    static let actionPlanPost = "/api/v1/seed/{seedId}/actionplan"
    static let actionPlanEdit = "/api/v1/actionplan/{actionPlanId}"
    static let actionPlanReview = "/api/v1/actionplan/{actionPlanId}/review"
    static let actionPlan = "/api/v1/actionplan/{actionplanId}"
    static let actionPlanScrap = "/api/v1/actionplan/{actionPlanId}/scrap"
    
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
    
    // MARK: - Ssuk
    
    static let gatheredSsuk = "/api/v1/member/{memberId}/gathered-ssuk"
    static let usedSsuk = "/api/v1/member/{memberId}/used-ssuk"
    
    // MARK: - MyPage
    
    static let myPageUserInfo = "/api/v1/member/{memberId}/profile"
    static let myPageGetEarnedSsuk = "/api/v1/member/{memberId}/gathered-ssuk"
    static let myPageGetSpentSsuk = "/api/v1/member/{memberId}/used-ssuk"
    
    // MARK: - Review
    
    static let review = "/api/v1/actionplan/{actionPlanId}/review"
    
    // MARK: - Auth
    
    static let socialLogin = "/api/v1/auth"
    static let tokenRefresh = "/api/v1/auth/token"
    static let bearer = "Bearer "
    static let memberWithdraw = "/api/v1/member/{memberId}"
}
