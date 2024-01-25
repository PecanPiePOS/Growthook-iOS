//
//  InsightListEmptyView.swift
//  Growthook
//
//  Created by KJ on 1/24/24.
//

import UIKit

import Then
import SnapKit

final class InsightListEmptyView: BaseView {

    // MARK: - UI Components
    
    private let emptyImage = UIImageView()
    private let emptyLabel = UILabel()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.backgroundColor = .clear
        
        emptyImage.do {
            $0.image = ImageLiterals.Component.ic_largethook_mono
        }
        
        emptyLabel.do {
            $0.text = "아직 심겨진 씨앗이 없어요"
            $0.font = .fontGuide(.body1_reg)
            $0.textColor = .gray200
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        self.addSubviews(emptyImage, emptyLabel)
        
        emptyImage.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImage.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
