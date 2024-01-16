//
//  CaveDTO.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/13/24.
//

import Foundation

struct CavePostRequest: Codable {
    let name: String
    let introduction: String
    let isShared: Bool
}

struct CavetPostResponse: Codable {
    let caveId: Int
}
