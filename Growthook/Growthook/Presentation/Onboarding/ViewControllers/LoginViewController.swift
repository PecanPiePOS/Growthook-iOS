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
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(SizeLiterals.Screen.screenHeight * 0.0948)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.4729)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(SizeLiterals.Screen.screenHeight * 0.1047)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(343)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.bottom.equalTo(kakaoLoginButton.snp.top).offset(-11)
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
        let model: LoginRequestDto = LoginRequestDto(socialPlatform: I18N.Auth.kakao, socialToken: APIConstants.deviceToken, userName: "")
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
            if let accessTokenData = data.accessToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
            }

            if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
            }
            UserDefaults.standard.set(data.nickname, forKey: I18N.Auth.nickname)
            UserDefaults.standard.set(data.memberId, forKey: I18N.Auth.memberId)
            UserDefaults.standard.set(true ,forKey: I18N.Auth.isLoggedIn)
            UserDefaults.standard.set(I18N.Auth.kakao, forKey: I18N.Auth.loginType)
            
            self?.loginSuccess()
        }
    }
    
    private func postAppleLogin() {
        let loginUserName = UserDefaults.standard.string(forKey: I18N.Auth.nickname) ?? I18N.Auth.nickname
        let model: LoginRequestDto = LoginRequestDto(socialPlatform: I18N.Auth.apple, socialToken: APIConstants.deviceToken, userName: loginUserName)
        
        AuthAPI.shared.postKakaoLogin(param: model) { [weak self]
            response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            APIConstants.jwtToken = data.accessToken
            APIConstants.refreshToken = data.refreshToken
            if let accessTokenData = data.accessToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
            }

            if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
            }
            UserDefaults.standard.set(data.nickname, forKey: I18N.Auth.nickname)
            UserDefaults.standard.set(data.memberId, forKey: I18N.Auth.memberId)
            UserDefaults.standard.set(true ,forKey: I18N.Auth.isLoggedIn)
            UserDefaults.standard.set(I18N.Auth.apple, forKey: I18N.Auth.loginType)
            /**
             위는 사용자가 로그인을 했는지 안 했는지 확인하는
             UserDefaults입니다.  SplashViewController의 96번 줄을 보세요
             */
            self?.loginSuccess()
        }
    }

    private func getNewToken() {
        AuthAPI.shared.getRefreshToken() { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            APIConstants.jwtToken = data.accessToken
            APIConstants.refreshToken = data.refreshToken
            if let accessTokenData = data.accessToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
            }

            if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
            }
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
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            if let userName = fullName {
                let nickname = "\(userName.familyName ?? "")\(userName.givenName ?? "")"
                if !nickname.isEmpty {
                    print("\(nickname)")
                    UserDefaults.standard.setValue(nickname, forKey: I18N.Auth.nickname)
                }
                else {
                    print("No userName")
                }
            }
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
                APIConstants.deviceToken = URLConstant.bearer + identifyTokenString
                self.postAppleLogin()
            }
            
            print("useridentifier: \(userIdentifier)") // 유저 고유의 id 값으로 자동로그인 처리에 할 수 있다
            print("UserName: \(fullName)")
            print(APIConstants.deviceToken)
            print("email: \(email)")
            UserDefaults.standard.setValue(userIdentifier, forKey: "userIdentifier")

            
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("username: \(username)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("login failed - \(error.localizedDescription)")
    }
}

