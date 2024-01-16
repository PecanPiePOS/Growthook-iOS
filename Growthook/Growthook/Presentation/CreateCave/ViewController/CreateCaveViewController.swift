//
//  CreateCaveViewController.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/12/23.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class CreateCaveViewController: UIViewController {
    
    private let createCaveView = CreateCaveView()
    private var viewModel = CreateCaveViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = createCaveView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        print(#function)
    }
}

extension CreateCaveViewController {
    
    private func bindViewModel() {
        
        createCaveView.nameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind { [weak self] value in
                guard let self else { return }
                self.viewModel.inputs.setName(with: value)
                self.createCaveView.nameCountLabel.text = "\(value.count)/7"
            }
            .disposed(by: disposeBag)
        
        createCaveView.nameTextField.rx.controlEvent([.editingDidBegin])
            .bind { [weak self] in
                guard let self else { return }
                createCaveView.nameTextField.focusWhenDidBeginEditing()
                self.setUpAnimation()
            }
            .disposed(by: disposeBag)
        
        createCaveView.nameTextField.rx.controlEvent([.editingDidEnd])
            .bind { [weak self] in
                guard let self else { return }
                createCaveView.nameTextField.unfocusWhenDidEndEditing()
                self.setDownAnimation()
            }
            .disposed(by: disposeBag)
        
        createCaveView.nameTextField.rx.controlEvent([.editingDidEndOnExit])
            .bind { [weak self] in
                guard let self else { return }
                self.setNextTextField()
            }.disposed(by: disposeBag)
        
        createCaveView.introduceTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind { [weak self] value in
                guard let self else { return }
                self.viewModel.inputs.setDescription(with: value)
                self.createCaveView.introduceCountLabel.text = "\(value.count.toTwoDigitsString())/20"
            }
            .disposed(by: disposeBag)
        
        createCaveView.introduceTextView.rx.didBeginEditing
            .bind { [weak self] in
                guard let self else { return }
                self.setUpAnimation()
            }
            .disposed(by: disposeBag)
        
        createCaveView.introduceTextView.rx.didEndEditing
            .bind { [weak self] in
                guard let self else { return }
                self.setDownAnimation()
            }
            .disposed(by: disposeBag)
        
        createCaveView.switchButton.rx.isOn
            .subscribe { [weak self] value in
                if value == true {
                    self?.setAlert()
                }
            }
            .disposed(by: disposeBag)
        
        createCaveView.createCaveButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.postCreateCave()
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.networkState
            .bind { [weak self] status in
                guard let self else { return }
                switch(status) {
                case .done:
                    self.pushToEmptyViewController()
                default: break
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.isValid
            .map { $0 ? true : false }
            .bind(to: createCaveView.createCaveButton.rx.enableStatus)
            .disposed(by: disposeBag)
        
        createCaveView.customNavigationBar.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func setUpAnimation() {
        UIView.animate(withDuration: 0.4, animations: { [self] in
            createCaveView.containerView.frame.origin.y -= 50
            createCaveView.createCaveButton.frame.origin.y -= SizeLiterals.Screen.screenHeight < 812 ? 50 : 280
            createCaveView.setLayoutUp()
        })
    }
    
    func setDownAnimation() {
        UIView.animate(withDuration: 0.4, animations: { [self] in
            createCaveView.containerView.frame.origin.y += 50
            createCaveView.createCaveButton.frame.origin.y += SizeLiterals.Screen.screenHeight < 812 ? 50 : 280
            createCaveView.setLayoutDown()
        })
    }
    
    private func setAlert() {
        AlertBuilder(viewController: self)
            .setTitle("내 동굴에 친구를 초대해\n인사이트를 공유해보세요")
            .setMessage("해당 기능은 추후 업데이트 예정이에요:)")
            .addActionConfirm("확인") {
                print("확인!!")
            }
            .show()
        setSwitchOff()
    }
    
    private func setSwitchOff() {
        createCaveView.switchButton.setOn(false, animated: true)
    }
    
    private func setNextTextField() {
        createCaveView.introduceTextView.becomeFirstResponder()
    }
    
    private func pushToEmptyViewController() {
        let vc = EmptyViewController()
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        vc.name = viewModel.outputs.name.value
        vc.introduction = viewModel.outputs.description.value
        vc.nickname = "쑥쑥이"
        self.present(vc, animated: true)
    }
}
