//
//  RemoveInsightAlertView.swift
//  Growthook
//
//  Created by KJ on 11/29/23.
//

import UIKit

import Then
import SnapKit

final class RemoveInsightAlertView: BaseView {

    // MARK: - UI Components
    
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let underLineView = UIView()
    private let keepButton = UIButton()
    private let removeButton = UIButton()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.backgroundColor = .black000.withAlphaComponent(0.5)
        
        contentView.do {
            $0.backgroundColor = .gray400
            $0.makeCornerRound(radius: 20)
        }
        
        titleLabel.do {
            $0.text = "정말로 삭제할까요?"
            $0.font = .fontGuide(.head4)
            $0.textColor = .white000
        }
        
        descriptionLabel.do {
            $0.text = "삭제한 인사이트는 다시 복구할 수 없으니\n신중하게 결정해 주세요!"
            $0.font = .fontGuide(.body3_reg)
            $0.textColor = .gray100
            $0.textAlignment = .center
            $0.numberOfLines = 2
        }
        
        keepButton.do {
            $0.setTitle("유지하기", for: .normal)
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.setTitleColor(.green400, for: .normal)
            $0.backgroundColor = .clear
        }
        
        removeButton.do {
            $0.setTitle("삭제하기", for: .normal)
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.setTitleColor(.gray200, for: .normal)
            $0.backgroundColor = .clear
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.addSubviews(contentView)
        contentView.addSubviews(titleLabel, descriptionLabel, keepButton, removeButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(34)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
        }
        
        keepButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 145 / 375)
            $0.height.equalTo(50)
        }
        
        removeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 145 / 375)
            $0.height.equalTo(50)
        }
    }
}
