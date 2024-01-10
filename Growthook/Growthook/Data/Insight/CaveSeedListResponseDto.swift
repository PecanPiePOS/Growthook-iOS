//
//  GetCaveSeedListResponseDto.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

struct CaveSeedListResponseDto: Codable {
    let seedId: Int
    let insight: String
    let remainingDays: Int
    let isLocked: Bool
    let isScraped: Bool
    let hasActionPlan: Bool
}
