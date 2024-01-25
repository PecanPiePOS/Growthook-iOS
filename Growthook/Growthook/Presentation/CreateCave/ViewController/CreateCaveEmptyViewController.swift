//
//  CreateCaveEmptyViewController.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/15/23.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class CreateCaveEmptyViewController: BaseViewController {

    private let emptyView = CaveEmptyView()
    private let viewModel = CreateCaveViewModel()
    private let disposeBag = DisposeBag()
    
    var name: String = ""
    var introduction: String = ""
    var nickname: String = ""
    
    override func loadView() {
        view = emptyView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
        setToast()
    }
    
    override func bindViewModel() {
        emptyView.navigationBar.closeButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        emptyView.plantSeedButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                let vc = CreatingNewInsightsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        emptyView.caveInfoView.sharedButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.setAlert()
            }
            .disposed(by: disposeBag)
    }
}

extension CreateCaveEmptyViewController {
    
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
    
    private func setAlert() {
        AlertBuilder(viewController: self)
            .setTitle("내 동굴에 친구를 초대해\n인사이트를 공유해보세요")
            .setMessage("해당 기능은 추후 업데이트 예정이에요:)")
            .addActionConfirm("확인") {
                print("확인!!")
            }
            .show()
    }
}
