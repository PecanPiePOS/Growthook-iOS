//
//  CreateActionViewModel.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/22/23.
//

import UIKit

import RxCocoa
import RxSwift
import RxRelay

protocol CreateActionViewModelInputs {
    func addActionPlan(with value: String)
    func setCount(count: Int)
    func postActionPlan(data: [ActionplanModel])
    func getSeedDetail()
    func setPlans(with value: [String])
}

protocol CreateActionViewModelOutputs {
    var networkState: BehaviorRelay<SomeNetworkStatus> { get }
    var name: BehaviorRelay<String> { get }
    var insight: BehaviorRelay<ActionPlanResponse> { get }
    var action: BehaviorRelay<[String]> { get }
    var countPlan: BehaviorRelay<Int> { get }
}

protocol CreateActionViewModelType {
    var inputs: CreateActionViewModelInputs { get }
    var outputs: CreateActionViewModelOutputs { get }
}

final class CreateActionViewModel: CreateActionViewModelInputs, CreateActionViewModelOutputs, CreateActionViewModelType {
    
    var specificPlan: [String] = []
    func addActionPlan(with value: String) {
        specificPlan.append(value)
        action.accept(specificPlan)
    }
    
    func setCount(count: Int) {
        countPlan.accept(count)
    }
    
    func postActionPlan(data: [ActionplanModel]) {
        setActionplanData(data: data)
        print(newActionPlan, "NEWACTIONPLAN")
        CreateActionService.postActionPlan(seedId: 107, actionPlan: newActionPlan)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.networkState.accept(.done)
            }, onError: { [weak self] error in
                guard let self else { return }
                self.networkState.accept(.error(error))
            })
            .disposed(by: disposeBag)
    }
    
    func getSeedDetail() {
        CreateActionService.getSeedDetail(seedId: 107)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.networkState.accept(.done)
                insight.accept(data)
            }, onError: { [weak self] error in
                guard let self else { return }
                self.networkState.accept(.error(error))
            })
            .disposed(by: disposeBag)
    }
    
    var newActionPlan: CreateActionRequest = CreateActionRequest(contents: [])
    func setActionplanData(data: [ActionplanModel]) {
        let placeholder = "구체적인 계획을 설정해보세요"
        print(data.count)
        for i in 0 ..< data.count {
            if data[i].content != placeholder {
                newActionPlan.contents.append(data[i].content ?? "")
            }
        }
    }
    
    func setPlans(with value: [String]) {
        action.accept(value)
    }

    var inputs: CreateActionViewModelInputs { return self }
    var outputs: CreateActionViewModelOutputs { return self }
    
    var networkState = BehaviorRelay<SomeNetworkStatus>(value: .normal)
    var name = BehaviorRelay<String>(value: "")
    var insight = BehaviorRelay<ActionPlanResponse>(value: ActionPlanResponse(caveName: "", insight: "", memo: "", source: "", url: "", isScraped: false, lockDate: "", remainingDays: 0))
    var action = BehaviorRelay<[String]>(value: [])
    var countPlan = BehaviorRelay<Int>(value: 1)
    
    private let disposeBag = DisposeBag()
    
    init() {
//        insight.accept(InsightModel.dummy())
    }
    
    private func setCountPlan() {
        
    }
}
