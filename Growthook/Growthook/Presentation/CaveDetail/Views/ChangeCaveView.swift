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
    let nameTextField = TextFieldBlockWithTitle(placeholder: "", maxLength: 7)
    let introduceTextView = TextViewBlockWithTitle(placeholder: "", maxLength: 20)
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
        
        nameTextField.do {
            $0.setMainTitleLabel(with: "이름")
        }
        
        introduceTextView.do {
            $0.setMainTitleLabel(with: "소개")
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
        
        self.addSubviews(navigationBar, nameTextField, introduceTextView,
                         isSharedLabel, isSharedButton)
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(28)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(103)
        }
        
        introduceTextView.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(123)
        }
        
        isSharedLabel.snp.makeConstraints {
            $0.top.equalTo(introduceTextView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(18)
        }
        
        isSharedButton.snp.makeConstraints {
            $0.top.equalTo(introduceTextView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(6)
            $0.width.equalTo(90)
            $0.height.equalTo(48)
        }
    }
}
