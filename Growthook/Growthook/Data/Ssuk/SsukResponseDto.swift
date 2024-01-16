//
//  GatheredSsukResponseGto.swift
//  Growthook
//
//  Created by KJ on 1/12/24.
//

import Foundation

struct SsukResponseDto: Codable {
    let gatheredSsuk: Int
}

extension SsukResponseDto {
    static func ssukDummy() -> SsukResponseDto {
        return SsukResponseDto(gatheredSsuk: 0)
    }
}
