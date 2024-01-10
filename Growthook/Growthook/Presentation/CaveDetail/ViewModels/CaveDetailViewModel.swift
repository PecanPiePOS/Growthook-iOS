//
//  CaveDetailViewModel.swift
//  Growthook
//
//  Created by KJ on 12/16/23.
//

import UIKit

import RxSwift
import RxCocoa

protocol CaveDetailViewModelInputs {
    func deleteButtonTapped()
}

protocol CaveDetailViewModelOutputs {
    var popToHome: PublishSubject<Void> { get }
}

protocol CaveDetailViewModelType {
    var inputs: CaveDetailViewModelInputs { get }
    var outputs: CaveDetailViewModelOutputs { get }
}

final class CaveDetailViewModel: CaveDetailViewModelInputs, CaveDetailViewModelOutputs, CaveDetailViewModelType {
    
    var popToHome: PublishSubject<Void> = PublishSubject<Void>()
    
    var inputs: CaveDetailViewModelInputs { return self }
    var outputs: CaveDetailViewModelOutputs { return self }
    
    init() {}
    
    func deleteButtonTapped() {
        self.popToHome.onNext(())
    }
}
