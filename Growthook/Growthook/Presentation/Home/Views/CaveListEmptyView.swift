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
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.addSubviews(emptyImage, emptyCaveLabel)
        
        emptyImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(80)
            $0.centerX.equalToSuperview()
        }
        
        emptyCaveLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImage.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
}
