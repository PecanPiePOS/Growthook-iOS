//
//  InsightsModel.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import Foundation

protocol TextLimits {
    var textLimit: Int { get }
}

struct InsightCaveModel {
    var caveId: Int
    var caveTitle: String
}

struct InsightPeriodModel {
    var periodMonthAsInteger: Int?
    var periodTitle: String
}

struct ActionPlanListModel {
    var content: String
    var isCompleted: Bool
}

struct PeriodModel {
    /// 변경 가능한 기한
    private static let maximumPeriodMonthCount: Int = 12
    
    static var periodSetToSelect: [InsightPeriodModel] {
        var periodSet: [InsightPeriodModel] = []
        
        for month in 1...maximumPeriodMonthCount {
            let bodyPeriodModel = InsightPeriodModel(periodMonthAsInteger: month, periodTitle: "\(month)개월")
            periodSet.append(bodyPeriodModel)
        }
        return periodSet
    }
}

enum InsightTextLimits: TextLimits {
    case insight
    case memo
    case reference
    
    var textLimit: Int {
        switch self {
        case .insight:
            return 30
        case .memo:
            return 300
        case .reference:
            return 20
        }
    }
}
