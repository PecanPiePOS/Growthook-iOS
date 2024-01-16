//
//  InsightList.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

struct InsightList {
        let seedId: Int
        let insight: String
        let remainingDays: Int
        let isLocked: Bool
        let isScraped: Bool
        let hasActionPlan: Bool
}

extension InsightList {
    static func insightDummy() -> [InsightList] {
        return [
            InsightList(seedId: 12, insight: "aaaa", remainingDays: 20, isLocked: false, isScraped: false, hasActionPlan: false)
        ]
    }
}
