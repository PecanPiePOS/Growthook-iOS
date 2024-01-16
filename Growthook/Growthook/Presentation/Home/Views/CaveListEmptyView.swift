//
//  CaveListEmptyView.swift
//  Growthook
//
//  Created by KJ on 1/10/24.
//

import UIKit

import Then
import SnapKit

final class CaveListEmptyView: BaseView {

    // MARK: - UI Components
    
    private lazy var emptyImage = UIImageView()
    private lazy var emptyCaveLabel = UILabel()
    lazy var checkButton = UIButton()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.backgroundColor = .clear
        
        emptyImage.do {
            $0.image = ImageLiterals.Home.img_emtpy_cave
        }
        
        emptyCaveLabel.do {
            $0.text = I18N.Home.emptyCaveList
            $0.font = .fontGuide(.body2_reg)
            $0.textColor = .gray200
        }
        
        checkButton.do {
            $0.setTitle(I18N.Component.Button.check, for: .normal)
            $0.backgroundColor = .green400
            $0.setTitleColor(.white000, for: .normal)
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.makeCornerRound(radius: 10)
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.addSubviews(emptyImage, emptyCaveLabel, checkButton)
        
        emptyImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(SizeLiterals.Screen.screenHeight * 80 / 812)
            $0.centerX.equalToSuperview()
        }
        
        emptyCaveLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImage.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        checkButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
    }
}
