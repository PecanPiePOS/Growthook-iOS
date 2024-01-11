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
    
    private let disposeBag = DisposeBag()
    private let deSelectInsightNotification = Notification.Name("DeSelectInsightNotification")
    
    override func bindViewModel() {
        removeInsightView.keepButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        removeInsightView.removeButton.rx.tap
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
