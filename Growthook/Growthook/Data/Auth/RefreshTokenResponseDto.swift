//
//  RefreshTokenResponseDto.swift
//  Growthook
//
//  Created by KJ on 1/18/24.
//

import Foundation

struct RefreshTokenResponseDto: Codable {
    let accessToken: String
    let refreshToken: String
}
