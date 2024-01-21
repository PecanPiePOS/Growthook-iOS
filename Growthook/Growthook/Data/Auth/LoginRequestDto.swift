//
//  LoginRequestDto.swift
//  Growthook
//
//  Created by KJ on 1/18/24.
//

import Foundation

struct LoginRequestDto: Codable {
    let socialPlatform: String
    let socialToken: String
}
