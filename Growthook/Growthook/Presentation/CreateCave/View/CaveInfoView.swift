//
//  EmptyCaveView.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/14/24.
//

import UIKit

import SnapKit
import Then

final class CaveInfoView: BaseView {
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let isSharedImageView = UIImageView()
    private let noSeedLabel = UILabel()
    private let scrapView = UIButton()
    private let mugwortView = UIImageView()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        self.backgroundColor = .gray700
        self.roundCorners(cornerRadius: 20, maskedCorners: [.topLeft, .topRight])
        
        titleLabel.do {
            $0.font = .fontGuide(.head4)
            $0.textColor = .white000
        }
        
        descriptionLabel.do {
            $0.font = .fontGuide(.body3_reg)
            $0.textColor = .gray100
        }
        
        nicknameLabel.do {
            $0.font = .fontGuide(.detail2_reg)
            $0.textColor = .gray200
        }
        
        isSharedImageView.do {
            $0.image = ImageLiterals.CaveDetail.btn_close
        }
        
        noSeedLabel.do {
            $0.text = "아직 심겨진 씨앗이 없어요"
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
        self.addSubviews(titleLabel, descriptionLabel, nicknameLabel, isSharedImageView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview().inset(100)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(1)
            $0.leading.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview().inset(100)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview().inset(100)
        }
        
        isSharedImageView.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(18)
            $0.leading.equalToSuperview().inset(6)
            $0.width.equalTo(90)
            $0.height.equalTo(48)
        }
    }
}

extension CaveInfoView {
    
    func bindModel(model: CaveDetailModel) {
        titleLabel.text = model.caveName
        descriptionLabel.text = model.introduction
        nicknameLabel.text = model.nickname
    }
}
