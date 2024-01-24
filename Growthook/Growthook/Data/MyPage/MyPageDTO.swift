//
//  MyPageDTO.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import Foundation

struct MyPageUserInfoResponse: Codable {
    let nickname: String
    let email: String
    let profileImage: String
}

struct MyPageEarnedSsukResponse: Codable {
    let gatheredSsuk: Int
}

struct MyPageSpentSsukResponse: Codable {
    let usedSsuk: Int
}
