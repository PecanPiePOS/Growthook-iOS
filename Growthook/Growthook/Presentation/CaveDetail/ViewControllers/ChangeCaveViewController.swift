//
//  CaveChangeViewController.swift
//  Growthook
//
//  Created by KJ on 1/14/24.
//

import UIKit

import Moya
import SnapKit
import Then
import RxCocoa
import RxSwift

final class ChangeCaveViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let changeCaveView = ChangeCaveView()
    private let vieWModel = ChangeCaveViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func bindViewModel() {
        changeCaveView.nameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind { [weak self] value in
                guard let self else { return }
                self.vieWModel.inputs.setName(value: value)
                self.setNameCount(value.count)
            }
            .disposed(by: disposeBag)
        
        changeCaveView.nameTextField.rx.controlEvent([.editingDidEndOnExit])
            .bind { [weak self] in
                guard let self else { return }
                self.setNextTextView()
            }
            .disposed(by: disposeBag)
        
        changeCaveView.introduceTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind { [weak self] value in
                guard let self else { return }
                self.vieWModel.inputs.setIntroduce(value: value)
                self.setIntroduceCount(value.count)
            }
            .disposed(by: disposeBag)
        
        vieWModel.outputs.isValid
            .map { $0 ? true : false }
            .bind(to: changeCaveView.navigationBar.rx.completionEnableStatus)
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.view.backgroundColor = .clear
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.view.addSubviews(changeCaveView)
        
        changeCaveView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ChangeCaveViewController {
    
    private func setNextTextView() {
        changeCaveView.introduceTextView.becomeFirstResponder()
    }
    
    private func setNameCount(_ count: Int) {
        changeCaveView.nameCountLabel.text = "\(count)/7"
    }
    
    private func setIntroduceCount(_ count: Int) {
        changeCaveView.introduceCountLabel.text = "\(count)/20"
    }
}
