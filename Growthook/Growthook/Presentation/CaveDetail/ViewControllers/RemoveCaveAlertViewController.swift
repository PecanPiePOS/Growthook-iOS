//
//  RemoveCaveViewController.swift
//  Growthook
//
//  Created by KJ on 1/10/24.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

final class RemoveCaveAlertViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let removeInsightView = RemoveAlertView()
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    private var caveId: Int?
    private let deSelectInsightNotification = Notification.Name("DeSelectInsightNotification")
    
    // MARK: - Initializer

    init(viewModel: HomeViewModel, caveId: Int){
        self.viewModel = viewModel
        self.caveId = caveId
        super.init(nibName: nil, bundle: nil)
    }
    
    override func bindViewModel() {
        removeInsightView.keepButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // 동굴 삭제
        removeInsightView.removeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let caveId = self?.caveId else { return }
                self?.viewModel.removeCaveButtonTap(caveId: caveId)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.removeCave
            .subscribe(onNext: { [weak self] in
                self?.clearInsight()
                self?.rootViewChange()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        view.backgroundColor = .clear
        
        removeInsightView.descriptionLabel.text = I18N.Component.RemoveAlert.removeCave
        
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        view.addSubviews(removeInsightView)
        
        removeInsightView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(173)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RemoveCaveAlertViewController {
    
    // MARK: - Methods
    
    private func clearInsight() {
        NotificationCenter.default.post(
            name: deSelectInsightNotification,
            object: nil,
            userInfo: ["type": ClearInsightType.deleteCave]
        )
    }
    
    private func rootViewChange() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            let vc = TabBarController()
            let rootVC = UINavigationController(rootViewController: vc)
            rootVC.navigationController?.isNavigationBarHidden = true
            window.rootViewController = rootVC
            window.makeKeyAndVisible()
        }
    }
}
