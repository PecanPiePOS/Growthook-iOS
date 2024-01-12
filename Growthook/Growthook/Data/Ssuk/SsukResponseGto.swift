//
//  GatheredSsukResponseGto.swift
//  Growthook
//
//  Created by KJ on 1/12/24.
//

import Foundation

struct SsukResponseGto: Codable {
    let gatheredSsuk: Int
}

extension SsukResponseGto {
    static func ssukDummy() -> SsukResponseGto {
        return SsukResponseGto(gatheredSsuk: 0)
    }
}
