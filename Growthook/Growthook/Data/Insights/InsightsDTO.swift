//
//  InsightsDTO.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import Foundation

struct InsightPostRequest: Codable {
    let insight, memo, source: String
    let url: String?
    let goalMonth: Int
}

struct InsightPostResponse: Codable {
    let seedId: Int
}
