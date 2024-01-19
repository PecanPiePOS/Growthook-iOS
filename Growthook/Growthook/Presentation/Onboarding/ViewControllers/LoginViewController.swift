//
//  LoginViewController.swift
//  Growthook
//
//  Created by KJ on 12/11/23.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import KakaoSDKAuth
import KakaoSDKUser

final class LoginViewController: BaseViewController {
    
    
    private let viewModel = OnboardingViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let loginView = LoginView()
    private let kakaoLoginButton = UIButton()
    private let appleLoginButton = UIButton()
    
    // MARK: - Properties
    
    override func bindViewModel() {
        kakaoLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.kakaoLogin()
            })
            .disposed(by: disposeBag)
    }
    
    override func setStyles() {
        view.backgroundColor = .gray700
        
        kakaoLoginButton.do {
            $0.setImage(ImageLiterals.Onboarding.kakao_login_large_wide, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFill
        }
        
        appleLoginButton.do {
            $0.setImage(ImageLiterals.Onboarding.btn_applelogin, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFill
        }
    }
    
    override func setLayout() {
    
        self.view.addSubviews(loginView, kakaoLoginButton, appleLoginButton)
        
        loginView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(77)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(388)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(loginView.snp.bottom).offset(105)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(343)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(343)
        }
    }
    
    private func kakaoLogin() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("✉️ loginWithKakaoTalk() success.")
                    guard let accessToken = oauthToken?.accessToken else { return }
                    APIConstants.deviceToken = URLConstant.bearer + accessToken
                    self.postKakaoLogin()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print(error)
                } else {
                    print("✉️ loginWithKakaoAccount() success.")
                    guard let accessToken = oauthToken?.accessToken else { return }
                    APIConstants.deviceToken = URLConstant.bearer + accessToken
                    self.postKakaoLogin()
                }
            }
        }
    }
    
    private func loginSuccess() {
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
    
    private func postKakaoLogin() {
        let model: LoginRequestDto = LoginRequestDto(socialPlatform: "KAKAO", socialToken: APIConstants.deviceToken)
        AuthAPI.shared.postKakaoLogin(param: model) { [weak self]
            response in
            guard let status = response?.status else { return }
            if status == 401 {
                self?.getNewToken()
                self?.postKakaoLogin()
                return
            }
            guard self != nil else { return }
            guard let data = response?.data else { return }
            APIConstants.jwtToken = data.accessToken
            APIConstants.refreshToken = data.refreshToken
            UserDefaults.standard.set(data.nickname, forKey: "nickname")
            UserDefaults.standard.set(data.memberId, forKey: "memberId")
            APIConstants.memberId = data.memberId
            self?.loginSuccess()
        }
    }
    
    private func getNewToken() {
        AuthAPI.shared.getRefreshToken() { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            APIConstants.jwtToken = data.accessToken
            APIConstants.refreshToken = data.refreshToken
        }
    }
}
