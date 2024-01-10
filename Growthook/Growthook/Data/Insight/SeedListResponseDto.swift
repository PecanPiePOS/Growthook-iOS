//
//  GetSeedListDto.swift
//  Growthook
//
//  Created by KJ on 1/10/24.
//

import Foundation

struct SeedListResponseDto: Codable {
    let seedId: Int
    let insight: String
    let remainingDays: Int
    let isLocked: Bool
    let isScraped: Bool
    let hasActionPlan: Bool
}
