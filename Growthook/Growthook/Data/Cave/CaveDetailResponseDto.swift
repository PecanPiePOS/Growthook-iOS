//
//  CaveDetailResponseDto.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

struct CaveDetailResponseDto: Codable {
    let caveName: String
    let introduction: String
    let nickname: String
    let isShared: Bool
}

extension CaveDetailResponseDto {
    static func caveDetailInitValue() -> CaveDetailResponseDto {
        return CaveDetailResponseDto(caveName: "", introduction: "", nickname: "", isShared: false)
    }
}
