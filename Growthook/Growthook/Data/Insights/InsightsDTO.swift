//
//  InsightsDTO.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import Foundation

// MARK: - Requests
struct InsightPostRequest: Codable {
    let insight, source: String
    let memo, url: String?
    let goalMonth: Int
}

struct InsightEditRequest: Codable {
    let insight, source: String
    let memo, url: String?
}

struct InsightActionPlanPatchRequest: Codable {
    var content: String
}

struct InsightAddExtraActionPlanRequest: Codable {
    var contents: [String]
}

// MARK: - Responses
struct InsightSuccessResponse: Codable {}

struct InsightPostResponse: Codable {
    let seedId: Int
}

struct InsightActionPlanResponse: Codable {
    let actionPlanId: Int
    var content: String
    var isScraped: Bool
    var isFinished: Bool
}

struct SeedDetailResponsse: Codable {
    let caveName, insight, source: String
    let memo: String?
    let url: String?
    let isScraped: Bool
    let lockDate: String
    let remainingDays: Int
}

//extension SeedDetailResponsse {
//    static let initData = Self.init(caveName: "", insight: "", memo: "", source: nil, url: "", isScraped: false, lockDate: "", remainingDays: 0)
//}

struct CaveSuccessResponse: Codable {
    let caveId: Int
    let caveName: String
}
