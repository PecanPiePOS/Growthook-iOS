//
//  InsightsViewModel.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 11/12/23.
//

import UIKit

import RxCocoa
import RxSwift

protocol InsightsViewModelInput {
    func addInsight(content: String)
    func addMemo(content: String)
    func selectCaveToAdd(of cave: InsightCaveModel)
    func addReference(content: String)
    func addReferenceUrl(content: String)
    func selectGoalPeriodToAdd(of period: InsightPeriodModel)
    func resetSelectedCave()
    func setPeriodSet()
}

protocol InsightsViewModelOutput {
    var myOwnCaves: Observable<[InsightCaveModel]> { get }
    var selectedCave: BehaviorRelay<InsightCaveModel?> { get }
    var availablePeriodList: [InsightPeriodModel] { get }
    var selectedPeriod: BehaviorRelay<InsightPeriodModel?> { get }
    var isRequirementsFilled: BehaviorRelay<Bool> { get }
}

protocol InsightsViewModelType {
    var inputs: InsightsViewModelInput { get }
    var outputs: InsightsViewModelOutput { get }
}

final class InsightsViewModel: InsightsViewModelOutput, InsightsViewModelInput, InsightsViewModelType {
    
    var availablePeriodList: [InsightPeriodModel] = []
    var myOwnCaves: Observable<[InsightCaveModel]>
    var selectedCave = BehaviorRelay<InsightCaveModel?>(value: nil)
    var selectedPeriod = BehaviorRelay<InsightPeriodModel?>(value: nil)
    var isRequirementsFilled = BehaviorRelay<Bool>(value: false)
    
    var inputs: InsightsViewModelInput { return self }
    var outputs: InsightsViewModelOutput { return self }
    
    init() {
        myOwnCaves = Observable.just([
            .init(caveId: 0, caveTitle: "Cave11"),
            .init(caveId: 1, caveTitle: "Cave12"),
            .init(caveId: 2, caveTitle: "Cave13"),
            .init(caveId: 3, caveTitle: "Cave14"),
            .init(caveId: 4, caveTitle: "Cave15"),
            .init(caveId: 5, caveTitle: "Cave16"),
            .init(caveId: 6, caveTitle: "Cave17")
        ])
    }
    
    func addInsight(content: String) {
        
    }
    
    func addMemo(content: String) {
        
    }
    
    func selectCaveToAdd(of cave: InsightCaveModel) {
        selectedCave.accept(cave)
    }
    
    
    func addReference(content: String) {
        
    }
    
    func addReferenceUrl(content: String) {
        
    }
    
    func selectGoalPeriodToAdd(of period: InsightPeriodModel) {
        selectedPeriod.accept(period)
    }
    
    func resetSelectedCave() {
        selectedCave.accept(nil)
    }
    
    func setPeriodSet() {
        availablePeriodList = PeriodModel.periodSetToSelect
    }
}
