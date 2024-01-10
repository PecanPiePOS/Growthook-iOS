//
//  GetSeedListDto.swift
//  Growthook
//
//  Created by KJ on 1/10/24.
//

import Foundation

struct GetSeedListResponseDto: Codable {
    let seedList: [Seed]
}

struct Seed: Codable {
    let seedId: Int
    let insight: String
    let remainingDays: Int
    let isLocked: Bool
    let isScraped: Bool
    let hasActionPlan: Bool
}

extension GetSeedListResponseDto {
    
    static func seedListDummy() -> [Seed] {
        return [
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: false, isScraped: false, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: false, isScraped: false, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: false, isScraped: false, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: false, isScraped: false, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: false, isScraped: false, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: true),
            Seed(seedId: 2, insight: "ㅇㅇㅇ", remainingDays: 5, isLocked: true, isScraped: true, hasActionPlan: false)
        ]
    }
}
