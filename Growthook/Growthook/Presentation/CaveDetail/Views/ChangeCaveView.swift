//
//  CaveChangeView.swift
//  Growthook
//
//  Created by KJ on 1/14/24.
//

import UIKit

import SnapKit
import Then

final class ChangeCaveView: BaseView {
    
    // MARK: - UI Components
    
    let navigationBar = CustomNavigationBar()
    private let nameLabel = UILabel()
    let nameTextField = UITextFieldWithTinitedWhenEdited(placeholders: "")
    let nameCountLabel = UILabel()
    private let introduceLabel = UILabel()
    let introduceTextView = UITextViewWithTintedWhenEdited(placeholder: "", maxLength: 20)
    let introduceCountLabel = UILabel()
    private let isSharedLabel = UILabel()
    private let isSharedButton = UIButton()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.backgroundColor = .gray600
        
        navigationBar.do {
            $0.isTitleViewIncluded = true
            $0.isBackButtonIncluded = true
            $0.isTitleLabelIncluded = "동굴 편집"
            $0.isCompletionButtonIncluded = true
            $0.isBackgroundColor = .gray600
        }
        
        nameLabel.do {
            $0.text = "이름"
            $0.font = .fontGuide(.body2_bold)
            $0.textColor = .white000
        }
        
        nameTextField.do {
            $0.returnKeyType = .done
        }
        
        nameCountLabel.do {
            $0.text = "0/7"
            $0.font = .fontGuide(.detail1_reg)
            $0.textColor = .gray300
        }
        
        introduceLabel.do {
            $0.text = "소개"
            $0.font = .fontGuide(.body2_bold)
            $0.textColor = .white000
        }
        
        introduceTextView.do {
            $0.returnKeyType = .done
            $0.textColor = .white000
            $0.font = .fontGuide(.body3_bold)
        }
        
        introduceCountLabel.do {
            $0.text = "00/20"
            $0.textColor = .gray300
            $0.font = .fontGuide(.detail1_reg)
        }
        
        isSharedLabel.do {
            $0.text = "공개 여부"
            $0.font = .fontGuide(.body2_bold)
            $0.textColor = .white000
        }
        
        isSharedButton.do {
            $0.setImage(ImageLiterals.Storage.close_btn, for: .normal)
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.addSubviews(navigationBar, nameLabel, nameTextField, nameCountLabel,
                         introduceLabel, introduceTextView, introduceCountLabel,
                         isSharedLabel, isSharedButton)
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(28)
            $0.leading.equalToSuperview().inset(18)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(48)
        }
        
        nameCountLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(22)
        }
        
        introduceLabel.snp.makeConstraints {
            $0.top.equalTo(nameCountLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel)
        }
        
        introduceTextView.snp.makeConstraints {
            $0.top.equalTo(introduceLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalTo(nameTextField)
            $0.height.equalTo(68)
        }
        
        introduceCountLabel.snp.makeConstraints {
            $0.top.equalTo(introduceTextView.snp.bottom).offset(4)
            $0.trailing.equalTo(nameCountLabel)
        }
        
        isSharedLabel.snp.makeConstraints {
            $0.top.equalTo(introduceCountLabel.snp.bottom).offset(16)
            $0.leading.equalTo(nameLabel)
        }
        
        isSharedButton.snp.makeConstraints {
            $0.top.equalTo(introduceCountLabel.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(6)
            $0.width.equalTo(90)
            $0.height.equalTo(48)
        }
    }
}
