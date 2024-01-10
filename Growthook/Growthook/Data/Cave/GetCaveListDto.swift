//
//  GetCaveListDto.swift
//  Growthook
//
//  Created by KJ on 1/10/24.
//

import Foundation

struct GetCaveListDto: Codable {
    let caveList: [Cave]
}

struct Cave: Codable {
    let caveId: Int
    let caveName: String
}

extension GetCaveListDto {
    
    static func caveListDummy() -> [Cave] {
        return [
            Cave(caveId: 10, caveName: "케이브")
        ]
    }
    
    static func caveEmptyDummy() -> [Cave] {
        return []
    }
}
