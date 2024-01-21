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
import AuthenticationServices

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
        
        appleLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleAuthorizationAppleIDButton()
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
        let model: LoginRequestDto = LoginRequestDto(socialPlatform: I18N.Auth.kakao, socialToken: APIConstants.deviceToken)
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
            UserDefaults.standard.set(data.nickname, forKey: I18N.Auth.nickname)
            UserDefaults.standard.set(data.memberId, forKey: I18N.Auth.memberId)
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


extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private func handleAuthorizationAppleIDButton() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] //유저로 부터 알 수 있는 정보들(name, email)
               
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    //로그인 성공
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // You can create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print()
                print("authCodeString: \(authCodeString)")
                print()
                print("identifyTokenString: \(identifyTokenString)")
            }
            
            print("useridentifier: \(userIdentifier)")
            print("fullName: \(fullName)")
            print("email: \(email)")
            
            //Move to MainPage
            //let validVC = SignValidViewController()
            //validVC.modalPresentationStyle = .fullScreen
            //present(validVC, animated: true, completion: nil)
//            self.loginSuccess()
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("username: \(username)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 로그인 실패(유저의 취소도 포함)
        print("login failed - \(error.localizedDescription)")
    }
}

