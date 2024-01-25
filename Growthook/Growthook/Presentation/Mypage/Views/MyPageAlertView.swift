//
//  MyPageAlertView.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/26/24.
//

import UIKit

import Then
import SnapKit

enum AlertType {
    case delete
    case logout
}

final class MyPageAlertView: BaseView {

    // MARK: - UI Components
    
    private let contentView = UIView()
    private let titleLabel = UILabel()
    var descriptionLabel = UILabel()
    private let underLineView = UIView()
    let keepButton = UIButton()
    let removeButton = UIButton()
    
    init(type: AlertType) {
        print(type)
        super.init(frame: .zero)
        if type == .delete {
            self.setDelete()
        } else {
            self.setLogout()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.backgroundColor = .black000.withAlphaComponent(0.5)
        
        contentView.do {
            $0.backgroundColor = .gray400
            $0.makeCornerRound(radius: 20)
        }
        
        titleLabel.do {
            $0.font = .fontGuide(.head4)
            $0.textColor = .white000
        }
        
        descriptionLabel.do {
            $0.font = .fontGuide(.body3_reg)
            $0.textColor = .gray100
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        underLineView.do {
            $0.backgroundColor = .gray200
        }
        
        keepButton.do {
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.setTitleColor(.green400, for: .normal)
            $0.backgroundColor = .clear
        }
        
        removeButton.do {
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.setTitleColor(.gray200, for: .normal)
            $0.backgroundColor = .clear
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.addSubviews(contentView)
        contentView.addSubviews(titleLabel, descriptionLabel, underLineView, keepButton, removeButton)
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 290 / 375)
            $0.height.equalTo(210)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(34)
            $0.centerX.equalToSuperview()
        }
        
        underLineView.snp.makeConstraints {
            $0.bottom.equalTo(keepButton.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        keepButton.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 145 / 375)
            $0.height.equalTo(50)
        }
        
        removeButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 145 / 375)
            $0.height.equalTo(50)
        }
    }
}

extension MyPageAlertView {
    func setDelete() {
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
        }
        titleLabel.text = I18N.Mypage.deleteTitle
        descriptionLabel.text = I18N.Mypage.deleteDescription
        descriptionLabel.setLineSpacingPartFontChange(lineSpacing: 5, targetString: descriptionLabel.text ?? "", font: .fontGuide(.body3_reg))
        descriptionLabel.textAlignment = .center
        keepButton.setTitle(I18N.Mypage.maintain, for: .normal)
        removeButton.setTitle(I18N.Mypage.withdraw, for: .normal)
    }
    
    func setLogout() {
        descriptionLabel.removeFromSuperview()
        titleLabel.text = I18N.Mypage.logoutTitle
        keepButton.setTitle(I18N.Mypage.cancel, for: .normal)
        removeButton.setTitle(I18N.Mypage.logout, for: .normal)
        
        contentView.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 290 / 375)
            $0.height.equalTo(140)
        }
    }
}
