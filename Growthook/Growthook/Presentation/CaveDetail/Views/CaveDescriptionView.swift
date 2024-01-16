//
//  CaveDescriptionView.swift
//  Growthook
//
//  Created by KJ on 12/16/23.
//

import UIKit

import Moya
import SnapKit
import Then

final class CaveDescriptionView: BaseView {

    // MARK: - UI Components
    
    private let caveTitle = UILabel()
    private let caveDescriptionLabel = UILabel()
    private let userImageView = UIImageView()
    private let nicknameLabel = UILabel()
    let lockButton = UIButton()
    
    // MARK: - Properties
    
    private var isShared: Bool = false
    
    override func setStyles() {
        
        self.backgroundColor = .gray600
        
        caveTitle.do {
            $0.font = .fontGuide(.head4)
            $0.textColor = .white
        }
        
        caveDescriptionLabel.do {
            $0.font = .fontGuide(.body3_reg)
            $0.textColor = .gray100
        }
        
        userImageView.do {
            $0.image = ImageLiterals.Home.img_cave
        }
        
        nicknameLabel.do {
            $0.font = .fontGuide(.detail2_reg)
            $0.textColor = .gray200
        }
        
        lockButton.do {
            $0.setImage(ImageLiterals.CaveDetail.btn_close, for: .normal)
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.addSubviews(caveTitle, caveDescriptionLabel,
                         userImageView, nicknameLabel, lockButton)
        
        caveTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalToSuperview().inset(18)
        }
        
        caveDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(caveTitle.snp.bottom).offset(1)
            $0.leading.equalTo(caveTitle)
        }
        
        userImageView.snp.makeConstraints {
            $0.top.equalTo(caveDescriptionLabel.snp.bottom).offset(16)
            $0.leading.equalTo(caveTitle)
            $0.size.equalTo(20)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(caveDescriptionLabel.snp.bottom).offset(19)
            $0.leading.equalTo(userImageView.snp.trailing).offset(10)
        }
        
        lockButton.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(6)
        }
    }
    
    // MARK: - Methods
    
    func configureView(_ model: CaveDetailResponseDto) {
        caveTitle.text = model.caveName
        caveDescriptionLabel.text = model.introduction
        nicknameLabel.text = model.nickname
        isShared = model.isShared
    }
}
