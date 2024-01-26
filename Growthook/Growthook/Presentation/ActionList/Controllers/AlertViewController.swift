//
//  AlertViewController.swift
//  Growthook
//
//  Created by 천성우 on 11/29/23.
//


import UIKit

import Moya
import RxCocoa
import RxSwift
import SnapKit
import Then

final class AlertViewController: BaseViewController {
    
    private var viewModel: ActionListViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let alertView = UIView()
    private let mainView = UIView()
    private let growthookImage = UIImageView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let separatorView = UIView()
    private let checkButton = UIButton()
    
    
    // MARK: - Properties
    
    
    // MARK: - Initializer
        
    init(viewModel: ActionListViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init() {
        let test = ActionListViewModel()
        self.init(viewModel: test)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindViewModel() {
        checkButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.didTapCheckButtonInAcertView()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        growthookImage.do {
            $0.image = ImageLiterals.Component.ic_largethook_color
        }
        
        mainView.do {
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .gray400
        }
        
        titleLabel.do {
            $0.font = .fontGuide(.head4)
            $0.numberOfLines = 2
            $0.text = "성장의 보상으로\n쑥을 얻었어요!"
            $0.textColor = .white000
            $0.textAlignment = .center
        }
        
        subTitleLabel.do {
            $0.font = .fontGuide(.body3_reg)
            $0.numberOfLines = 3
            $0.text = "한 단계 쑥! 성장한 것을 축하해요\n수확한 쑥을 통해\n씨앗의 잠금을 해제해보세요:)"
            $0.textColor = .gray100
            $0.textAlignment = .center
        }
        
        separatorView.do {
            $0.backgroundColor = .gray100
        }
        
        checkButton.do {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(.green400, for: .normal)
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        view.addSubviews(alertView)
        alertView.addSubviews(mainView, growthookImage, titleLabel, subTitleLabel, separatorView, checkButton)
        
        
        alertView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.7733)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.3827)
        }
        
        growthookImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.1158)
        }
        
        mainView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(SizeLiterals.Screen.screenHeight * 0.0591)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.299)
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.7733)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(growthookImage.snp.bottom).offset(SizeLiterals.Screen.screenHeight * 0.0148)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.5893)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.0665)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(SizeLiterals.Screen.screenHeight * 0.0049)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.488)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.0776)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(SizeLiterals.Screen.screenHeight * 0.0419)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.0006)
        }
        
        checkButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.7733)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.0603)
        }
    }
    
    // MARK: - Methods
    
    
    
    // MARK: - @objc Methods
    
    @objc
    private func didTapCheckButton() {
        dismiss(animated: false, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

