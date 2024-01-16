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
    var remainingDays: Int
    var isLocked: Bool
    var isScraped: Bool
    var hasActionPlan: Bool
}
