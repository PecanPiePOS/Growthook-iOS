//
//  MyPageUserInformationViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import UIKit

import RxSwift

final class MyPageUserInformationViewController: BaseViewController {

    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()
    
    private let customNavigationView = CommonCustomNavigationBar()
    private let profileImageView = UIImageView()
    private let nicknameBlock = MyPageUserInfoBlockView()
    private let signedAccountBlock = MyPageUserInfoBlockView()
    private let withdrawalButton = UIButton()
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // TODO: 로그아웃 및 회원탈퇴 로직 구현해야함 API 도! -
    
    override func bindViewModel() {
        customNavigationView.rxBackButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // TODO: 탈퇴 팝업 뷰 만들기
        
        viewModel.outputs.userProfileName
            .bind { [weak self] name in
                guard let self else { return }
                self.nicknameBlock.setInformation(with: name)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.userEmail
            .bind { [weak self] account in
                guard let self else { return }
                self.signedAccountBlock.setInformation(with: account)
            }
            .disposed(by: disposeBag)
    }
    
    override func setStyles() {
        view.backgroundColor = .gray700
        
        customNavigationView.do {
            $0.hideDoneButton()
            $0.setTitle(with: "내 정보 조회")
        }
        
        withdrawalButton.do {
            $0.setTitle("회원 탈퇴", for: .normal)
            $0.setTitleColor(.gray300, for: .normal)
            $0.titleLabel?.font = .fontGuide(.detail3_reg)
            $0.setUnderline()
        }
        
        profileImageView.do {
            $0.image = UIImage(named: "DefaultUserImage")
            $0.contentMode = .scaleAspectFill
            $0.makeCornerRound(radius: 41)
        }
        
        nicknameBlock.do {
            $0.setTitle(with: "닉네임")
        }
        
        signedAccountBlock.do {
            $0.setTitle(with: "연결된 계정")
        }
    }
    
    override func setLayout() {
        
        view.addSubviews(
            customNavigationView, profileImageView, nicknameBlock,
            signedAccountBlock, withdrawalButton
        )
        
        customNavigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 48 / 812)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom).offset(21)
            $0.size.equalTo(82)
            $0.centerX.equalToSuperview()
        }
        
        nicknameBlock.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(75)
        }
        
        signedAccountBlock.snp.makeConstraints {
            $0.top.equalTo(nicknameBlock.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(75)
        }
        
        withdrawalButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(18)
            $0.bottom.equalToSuperview().inset(55)
            $0.height.equalTo(21)
            $0.width.equalTo(44)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
