//
//  GetSeedAlarmResponseDto.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

struct SeedAlarmResponseDto: Codable {
    let seedCount: Int
}

extension SeedAlarmResponseDto {
    static func alarmInitValue() -> SeedAlarmResponseDto {
        return SeedAlarmResponseDto(seedCount: 0)
    }
}
