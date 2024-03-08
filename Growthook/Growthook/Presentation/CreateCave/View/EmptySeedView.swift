//
//  EmptySeedView.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/15/23.
//

import UIKit

import SnapKit
import Then

final class EmptySeedView: BaseView {
    
    // MARK: - UI Components
    
    private let noSeedLabel = UILabel()
    private let scrapView = UIButton()
    private let mugwortView = UIImageView()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        self.backgroundColor = .gray700
        self.roundCorners(cornerRadius: 20, maskedCorners: [.topLeft, .topRight])
        
        noSeedLabel.do {
            $0.text = I18N.Home.emptySeedList
            $0.font = .fontGuide(.body1_reg)
            $0.textColor = .gray200
        }
        
        scrapView.do {
            $0.setImage(ImageLiterals.Scrap.btn_scrap_default, for: .normal)
        }
        
        mugwortView.do {
            $0.image = ImageLiterals.Component.ic_largethook_mono
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        self.addSubviews(noSeedLabel, scrapView, mugwortView)

        scrapView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(44)
            $0.trailing.equalToSuperview().inset(18)
        }
        
        mugwortView.snp.makeConstraints {
            $0.top.lessThanOrEqualTo(scrapView.snp.bottom).offset(80)
            $0.centerX.equalToSuperview()
        }
        
        noSeedLabel.snp.makeConstraints {
            $0.top.equalTo(mugwortView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
