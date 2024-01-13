//
//  CreateCaveViewModel.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/12/23.
//

import UIKit

import RxCocoa
import RxSwift
import RxRelay

protocol CreateCaveViewModelInputs {
    func setName(with value: String)
    func setDescription(with value: String)
    func switchTapped()
    func createButtonTapped()
    func postCreateCave()
}

protocol CreateCaveViewModelOutput {
    var networkState: BehaviorRelay<SomeNetworkStatus> { get }
    var name: BehaviorRelay<String> { get }
    var description: BehaviorRelay<String> { get }
    var caveModel: BehaviorRelay<CreateCaveModel> { get }
    var switchStatus: BehaviorRelay<Bool> { get }
    var isValid: Observable<Bool> { get }
}

protocol CreateCaveViewModelType {
    var inputs: CreateCaveViewModelInputs { get }
    var outputs: CreateCaveViewModelOutput { get }
}

final class CreateCaveViewModel: CreateCaveViewModelInputs, CreateCaveViewModelOutput, CreateCaveViewModelType {
    
    func setName(with value: String) {
        name.accept(value)
    }
    
    func setDescription(with value: String) {
        description.accept(value)
    }
    
    func switchTapped() {
        print("switchTapped")
    }
    private let createCaveService = CreateCaveService()

    func createButtonTapped() {
        caveModel.accept(CreateCaveModel(name: name.value, description: description.value))
        print(name.value, description.value, switchStatus.value, "++++++++++++")
        
    }
    
    func postCreateCave() {
        let newCave = CreateCaveRequest(name: name.value, introduction: description.value, isShared: switchStatus.value)
        CreateCaveService.postcave(memberId: 4, cave: newCave)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.networkState.accept(.done)
            }, onError: { [weak self] error in
                guard let self else { return }
                self.networkState.accept(.error(error))
            })
            .disposed(by: disposeBag)
    }
    
    var inputs: CreateCaveViewModelInputs { return self }
    var outputs: CreateCaveViewModelOutput { return self }
    
    var networkState = BehaviorRelay<SomeNetworkStatus>(value: .normal)
    var name = BehaviorRelay<String>(value: "")
    var description = BehaviorRelay<String>(value: "")
    var caveModel: BehaviorRelay<CreateCaveModel> = BehaviorRelay(value: CreateCaveModel(name: "", description: ""))
    var switchStatus: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isValid: Observable<Bool> {
        return BehaviorRelay.combineLatest(name, description)
            .map { name, description in
                return !name.isEmpty && description != "동굴을 간략히 소개해주세요"
            }
    }
    
    private let disposeBag = DisposeBag()
    
    
    init() {
        self.switchStatus.accept(false)
    }
}
