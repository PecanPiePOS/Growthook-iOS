//
//  ChangeCaveViewModel.swift
//  Growthook
//
//  Created by KJ on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift
import RxRelay

protocol ChangeCaveViewModelInputs {
    func setName(value: String)
    func setIntroduce(value: String)
}

protocol ChangeCaveViewModelOutput {
    var name: BehaviorRelay<String> { get }
    var introduce: BehaviorRelay<String> { get }
    var isValid: Observable<Bool> { get }
}

protocol ChangeCaveViewModelType {
    var inputs: ChangeCaveViewModelInputs { get }
    var outputs: ChangeCaveViewModelOutput { get }
}

final class ChangeCaveViewModel: ChangeCaveViewModelInputs, ChangeCaveViewModelOutput, ChangeCaveViewModelType {
    
    func setName(value: String) {
        name.accept(value)
    }
    
    func setIntroduce(value: String) {
        introduce.accept(value)
    }
    
    var name: BehaviorRelay<String> = BehaviorRelay(value: "")
    var introduce: BehaviorRelay<String> = BehaviorRelay(value: "")
    var isValid: Observable<Bool> {
        return BehaviorRelay.combineLatest(name, introduce)
            .map { name, introduce in
                return !name.isEmpty && !introduce.isEmpty
            }
    }
    
    var inputs: ChangeCaveViewModelInputs { return self }
    var outputs: ChangeCaveViewModelOutput { return self }
    
    init() {}
}
