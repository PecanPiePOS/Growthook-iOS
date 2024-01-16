//
//  EmptyViewController.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/15/23.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class EmptyViewController: BaseViewController {

    private let emptyView = CaveEmptyView()
    private let viewModel = CreateCaveViewModel()
    private let disposeBag = DisposeBag()
    
    var name: String = ""
    var introduction: String = ""
    var nickname: String = ""
    
    override func loadView() {
        view = emptyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setToast()
    }
    
    override func bindViewModel() {
        emptyView.navigationBar.closeButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        emptyView.plantSeedButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                // TODO: Connect
            }
            .disposed(by: disposeBag)
    }
}

extension EmptyViewController {
    
    private func setToast() {
        view.showToast(message: "새 동굴을 만들었어요!")
    }
    
    private func tapCloseButton(_ sender: Any) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
        } else {
            self.dismiss(animated: false)
        }
    }
    
    private func bindModel() {
        emptyView.bindModel(model: CaveDetailModel(caveName: self.name, introduction: self.introduction, nickname: self.nickname, isShared: false))
    }
}
