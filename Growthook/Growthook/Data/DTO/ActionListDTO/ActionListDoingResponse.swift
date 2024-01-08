//
//  ActionListDoingResponse.swift
//  Growthook
//
//  Created by 천성우 on 1/8/24.
//

import Foundation

struct ActionListDoingResponse: Codable {
    let actionPlanID: Int
    let content: String
    let isScraped: Bool
    let seedID: Int
    
    func convertToActionListDoingModel() -> ActionListDoingModel {
        return ActionListDoingModel(actionPlanID: actionPlanID, content: content, isScraped: isScraped, seedID: seedID)
    }
}
