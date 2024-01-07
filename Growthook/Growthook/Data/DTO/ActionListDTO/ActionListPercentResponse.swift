//
//  ActionListPercentResponse.swift
//  Growthook
//
//  Created by 천성우 on 1/7/24.
//

import Foundation

struct ActionListPercentResponse: Codable {
    let data: Int
    
    func convertToActionListPersentModel() -> ActionListPersentModel {
        return ActionListPersentModel(actionListPersent: data)
    }
}

