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

struct PeriodModel {
    /// 변경 가능한 기한
    private static let maximumPeriodMonthCount: Int = 12
    
    static var periodSetToSelect: [InsightPeriodModel] {
        var periodSet: [InsightPeriodModel] = []
        let defaultCase = InsightPeriodModel(periodMonthAsInteger: nil, periodTitle: "선택")
        periodSet.append(defaultCase)
        
        for month in 1...maximumPeriodMonthCount {
            let bodyPeriodModel = InsightPeriodModel(periodMonthAsInteger: month, periodTitle: "\(month)개월")
            periodSet.append(bodyPeriodModel)
        }
        return periodSet
    }
}

struct InsightCaveModel {
    var caveId: Int
    var caveTitle: String
}

struct InsightPeriodModel {
    var periodMonthAsInteger: Int?
    var periodTitle: String
}
