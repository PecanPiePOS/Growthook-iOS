//
//  CustomNavigationBar.swift
//  Growthook
//
//  Created by KJ on 11/10/23.
//

import UIKit

import Then
import SnapKit

final class CustomNavigationBar: UIView {
    
    // MARK: - UI Components

    private lazy var titleView = UIView()
    private lazy var titleLabel = UILabel()
    lazy var backButton = UIButton()
    lazy var closeButton = UIButton()
    lazy var menuButton = UIButton()
    lazy var completionButton = UIButton()
    
    // MARK: - Properties
    
    var isTitleLabelIncluded: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var isTitleViewIncluded: Bool {
        get { !titleView.isHidden }
        set { titleView.isHidden = !newValue }
    }
    
    var isBackButtonIncluded: Bool {
        get { !backButton.isHidden }
        set { backButton.isHidden = !newValue }
    }
    
    var isCloseButtonIncluded: Bool {
        get { !closeButton.isHidden }
        set { closeButton.isHidden = !newValue }
    }
    
    var isMenuButtonIncluded: Bool {
        get { !menuButton.isHidden }
        set { menuButton.isHidden = !newValue }
    }
    
    var isBackgroundColor: UIColor? {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    
    var isCompletionButtonIncluded: Bool {
        get { !completionButton.isHidden }
        set { completionButton.isHidden = !newValue }
    }
    
    var completionEnableStatus: Bool = false {
        didSet {
            switch completionEnableStatus {
            case true: setEnable()
            case false: setDisable()
            }
        }
    }
    
    var backButtonAction: (() -> Void)?
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomNavigationBar {
    
    // MARK: - UI Components Property
    
    private func setUI() {
        
        self.backgroundColor = .gray700
        
        titleView.do {
            $0.isHidden = true
        }
        
        titleLabel.do {
            $0.font = .fontGuide(.body1_reg)
            $0.textColor = .white000
        }
        
        backButton.do {
            $0.setImage(ImageLiterals.NavigationBar.back, for: .normal)
            $0.isHidden = true
        }
        
        closeButton.do {
            $0.setImage(ImageLiterals.NavigationBar.close, for: .normal)
            $0.isHidden = true
            $0.isEnabled = true
        }
        
        menuButton.do {
            $0.setImage(ImageLiterals.NavigationBar.menu, for: .normal)
            $0.isHidden = true
        }
        
        completionButton.do {
            $0.setTitle("완료", for: .normal)
            $0.setTitleColor(.gray300, for: .normal)
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.backgroundColor = .clear
            $0.isHidden = true
        }
    }
    
    // MARK: - Layout Helper
    
    private func setLayout() {
        
        self.addSubviews(backButton, closeButton, menuButton, titleView, completionButton)
        titleView.addSubview(titleLabel)
        
        self.snp.makeConstraints {
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 48 / 812)
        }
        
        titleView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(48)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(48)
        }
        
        menuButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
        
        completionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(48)
        }
    }
    
    @objc private func backButtonTapped() {
        backButtonAction?()
    }

    func setupBackButtonTarget() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
}

extension CustomNavigationBar {
    
    func setEnable() {
        completionButton.do {
            $0.setTitleColor(.green400, for: .normal)
            $0.isEnabled = true
        }
    }
    
    func setDisable() {
        completionButton.do {
            $0.setTitleColor(.gray300, for: .normal)
            $0.isEnabled = false
        }
    }
}
