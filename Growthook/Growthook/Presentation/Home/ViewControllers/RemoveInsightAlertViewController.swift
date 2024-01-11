//
//  RemoveInsightAlertViewController.swift
//  Growthook
//
//  Created by KJ on 11/29/23.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

final class RemoveInsightAlertViewController: BaseViewController {
    
    // MARK: - UI Components

    private let removeInsightView = RemoveAlertView()
    
    // MARK: - Properties
    
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    private let deSelectInsightNotification = Notification.Name("DeSelectInsightNotification")
    
    override func bindViewModel() {
        removeInsightView.keepButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.keepInsight()
                self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
        removeInsightView.removeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.clearInsight()
                                self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - UI Components Property
    
    override func setStyles() {
        
        view.backgroundColor = .clear
        
        removeInsightView.descriptionLabel.text = I18N.Component.RemoveAlert.removeInsight

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

extension RemoveInsightAlertViewController {
    
    // MARK: - Methods
    
    private func clearInsight() {
        NotificationCenter.default.post(
            name: deSelectInsightNotification,
            object: nil,
            userInfo: ["type": ClearInsightType.delete]
        )
    }
    
    private func keepInsight() {
        NotificationCenter.default.post(
            name: deSelectInsightNotification,
            object: nil,
            userInfo: ["type": ClearInsightType.none]
        )
    }
}
