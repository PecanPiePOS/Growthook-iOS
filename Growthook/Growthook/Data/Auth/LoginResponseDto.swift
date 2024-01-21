//
//  LoginResponseDto.swift
//  Growthook
//
//  Created by KJ on 1/18/24.
//

import Foundation

struct LoginResponseDto: Codable {
    let nickname: String
    let memberId: Int
    let accessToken: String
    let refreshToken: String
}
