//
//  SplashViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 11/12/23.
//

import UIKit

import Lottie

final class SplashViewController: BaseViewController {

    private let splashLottieView: LottieAnimationView = LottieAnimationView(name: "grothooksplash", configuration: LottieConfiguration(renderingEngine: .mainThread))
    private let splashLabel = UILabel()
    private let splashImageView = UIImageView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            var mainViewController: UIViewController
            
            if self.isFirstLaunch() {
                mainViewController = OnboardingSelectViewController()
            } else {
                mainViewController = TabBarController()
                (mainViewController as? TabBarController)?.selectedIndex = 0
            }

            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }

            sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: mainViewController)
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    override func setStyles() {
        view.backgroundColor = .gray700.withAlphaComponent(0.9)
        
//        splashLottieView.animationSpeed = 0.8
//        splashLottieView.play { _ in
//            var mainViewController: UIViewController
//        
//            if self.isFirstLaunch() {
//                mainViewController = OnboardingSelectViewController()
//            } else {
//                mainViewController = TabBarController()
//                (mainViewController as? TabBarController)?.selectedIndex = 0
//            }
//            
//            guard let sceneDeleagate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
//            
//            sceneDeleagate.window?.rootViewController = UINavigationController(rootViewController: mainViewController)
//            sceneDeleagate.window?.makeKeyAndVisible()
//        }
        
        splashLabel.do {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let attributedText = NSAttributedString(
                string: "일상 속 영감이\n성장의 거름으로",
                attributes: [
                    .foregroundColor: UIColor.white000,
                    .font: UIFont.fontGuide(.body1_reg),
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            $0.attributedText = attributedText
            $0.textAlignment = .center
            $0.numberOfLines = 2
        }
        
        splashImageView.do {
            $0.image = ImageLiterals.Onboarding.growthook_Splash
            $0.contentMode = .scaleAspectFit
        }
    }
    
    override func setLayout() {
        view.addSubviews(splashLabel, splashImageView)
        
        splashLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(splashImageView.snp.top).inset(7)
        }
        
        splashImageView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(491)
        }
    }
    
    //MARK: - Methods
    
    /**
     어플리케이션이 최초로 실행되었는지를 확인하는 메소드입니다
     로그인 기능이 아직 최종 구현이 되지 않았기에 아래처럼 구현 하였습니다
    */
    
    private func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBefore = UserDefaults.standard.bool(forKey: "hasBeenLaunchedBefore")
        if !hasBeenLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBefore")
        }
        return !hasBeenLaunchedBefore
    }
}
