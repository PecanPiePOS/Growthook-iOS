//
//  CreateCaveView.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/12/23.
//

import UIKit

import SnapKit
import Then

final class CreateCaveView: BaseView {
    
    let customNavigationBar = CustomNavigationBar()
    let containerView = UIView()
    private let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    private let nameLabel = UILabel()
    let nameTextField = CommonTextFieldWithBorder(placeholder: "동굴의 이름을 알려주세요", maxLength: 7)
    let nameCountLabel = UILabel()
    private let introduceLabel = UILabel()
    let introduceTextView = CommonTextViewWithBorder(placeholder: "동굴을 간략히 소개해주세요", maxLength: 20)
    let introduceCountLabel = UILabel()
    private let shareLabel = UILabel()
    let switchButton = UISwitch()
    let createCaveButton = BottomCTAButton(type: .createNewCave)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setStyles() {
        self.backgroundColor = .gray700
        
        customNavigationBar.do {
            $0.isCloseButtonIncluded = true
        }
        
        titleLabel.do {
            $0.text = "새 동굴 짓기"
            $0.font = .fontGuide(.head1)
            $0.textColor = .white000
        }
        
        descriptionLabel.do {
            $0.text = "새로운 동굴을 지어,\n나만의 인사이트를 마음껏 담아보세요."
            $0.font = .fontGuide(.body2_reg)
            $0.textColor = .white000
            $0.numberOfLines = 2
            $0.setLineSpacing(lineSpacing: 6)
        }
        
        nameLabel.do {
            $0.text = "이름"
            $0.textColor = .green400
            $0.font = .fontGuide(.head4)
        }
        
        nameTextField.do {
            $0.returnKeyType = .done
        }
        
        nameCountLabel.do {
            $0.text = "0/7"
            $0.textColor = .gray300
            $0.font = .fontGuide(.detail1_reg)
        }
        
        introduceLabel.do {
            $0.text = "소개"
            $0.textColor = .green400
            $0.font = .fontGuide(.head4)
        }
        
        introduceTextView.do {
            $0.returnKeyType = .done
        }
        
        introduceCountLabel.do {
            $0.text = "0/20"
            $0.textColor = .gray300
            $0.font = .fontGuide(.detail1_reg)
        }
        
        shareLabel.do {
            $0.text = "공개하기"
            $0.textColor = .green400
            $0.font = .fontGuide(.head4)
        }
        
        switchButton.do {
            $0.onTintColor = .green400
            $0.tintColor = .gray400
        }
    }
    
    override func setLayout() {
        self.addSubviews(customNavigationBar, containerView, createCaveButton)
        containerView.addSubviews(titleLabel, descriptionLabel, nameLabel, nameTextField, nameCountLabel, introduceLabel, introduceTextView, introduceCountLabel, shareLabel, switchButton)
        
        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 48 / 812)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(52)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(431)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(29)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(34)
            $0.horizontalEdges.equalToSuperview()
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        nameCountLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(4)
        }
        
        introduceLabel.snp.makeConstraints {
            $0.top.equalTo(nameCountLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
        }
        
        introduceTextView.snp.makeConstraints {
            $0.top.equalTo(introduceLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(68)
        }
        
        introduceCountLabel.snp.makeConstraints {
            $0.top.equalTo(introduceTextView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(4)
        }
        
        shareLabel.snp.makeConstraints {
            $0.top.equalTo(introduceCountLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
        }
        
        switchButton.snp.makeConstraints {
            $0.top.equalTo(shareLabel.snp.bottom).offset(11)
            $0.leading.equalToSuperview().inset(3)
        }
        
        createCaveButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
        }
    }
}

extension CreateCaveView {
    func setLayoutUp() {
        containerView.snp.remakeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(2)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(431)
        }
        
        if(SizeLiterals.Screen.screenHeight < 812) {
            createCaveButton.snp.remakeConstraints {
                $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(68)
                $0.horizontalEdges.equalToSuperview().inset(18)
                $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
            }
        }
        
        else {
            createCaveButton.snp.remakeConstraints {
                $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(298)
                $0.horizontalEdges.equalToSuperview().inset(18)
                $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
            }
        }
    }
    
    func setLayoutDown() {
        containerView.snp.updateConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(52)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(431)
        }
        
        createCaveButton.snp.updateConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(18)
        }
    }
}

extension CreateCaveView {
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return self.nameTextField.becomeFirstResponder()
    }
}
