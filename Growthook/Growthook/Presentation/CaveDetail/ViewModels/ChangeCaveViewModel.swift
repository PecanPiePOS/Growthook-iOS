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
    func completionButtonTap(caveId: Int)
}

protocol ChangeCaveViewModelOutput {
    var name: BehaviorRelay<String> { get }
    var introduce: BehaviorRelay<String> { get }
    var isValid: Observable<Bool> { get }
    var changeCave: PublishSubject<Void> { get }
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
    
    func completionButtonTap(caveId: Int) {
        patchCave(caveId: caveId)
    }
    
    var name: BehaviorRelay<String> = BehaviorRelay(value: "")
    var introduce: BehaviorRelay<String> = BehaviorRelay(value: "")
    var isValid: Observable<Bool> {
        return BehaviorRelay.combineLatest(name, introduce)
            .map { name, introduce in
                return !name.isEmpty && !introduce.isEmpty
            }
    }
    var changeCave: PublishSubject<Void> = PublishSubject<Void>()
    
    var inputs: ChangeCaveViewModelInputs { return self }
    var outputs: ChangeCaveViewModelOutput { return self }
    
    init() {}
}

extension ChangeCaveViewModel {
    
    func patchCave(caveId: Int) {
        let caveId = caveId
        let model: CavePatchRequestDto = CavePatchRequestDto(name: name.value, introduction: introduce.value, isShared: false)
        CaveAPI.shared.patch(caveId: caveId, param: model) { [weak self] response in
            guard let status = response?.status else { return }
            self?.changeCave.onNext(())
        }
    }
    
    private func getNewToken() {
        AuthAPI.shared.getRefreshToken() { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            if let accessTokenData = data.accessToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
            }

            if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
            }
            APIConstants.jwtToken = data.accessToken
            APIConstants.refreshToken = data.refreshToken
        }
    }
}
