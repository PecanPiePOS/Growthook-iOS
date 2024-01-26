//
//  LogoutAlertViewController.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/26/24.
//


import UIKit

import RxSwift

final class LogoutAlertViewController: BaseViewController {
    private let logoutAlertView = MyPageAlertView(type: .logout)

    private let viewModel = MyPageViewModel()
    private let disposeBag = DisposeBag()
    
    override func setStyles() {
        view.backgroundColor = .clear
    }
    
    override func setLayout() {
        view.addSubview(logoutAlertView)
        logoutAlertView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        
        logoutAlertView.keepButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        
        logoutAlertView.removeButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.logOutDidTap()
                self.logout()
            }
            .disposed(by: disposeBag)
    }
}

extension LogoutAlertViewController {
    
    private func logout() {
        // 여기에 로그아웃 시 필요한 처리를 추가합니다.
        // 예를 들어, 사용자 세션을 초기화하고 로그아웃 API 호출 등을 수행합니다.

        // 모든 화면을 닫고 SplashViewController를 엽니다.
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            let splashViewController = SplashViewController()
            let rootViewController = UINavigationController(rootViewController: splashViewController)
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
        }
    }
}
