//
//  NotificationAlertView.swift
//  Growthook
//
//  Created by KJ on 11/30/23.
//

import UIKit

import SnapKit
import Then

final class NotificationAlertView: BaseView {

    // MARK: - UI Components
    
    let lockImage = UIImageView()
    let notiLabel1 = UILabel()
    let notiLabel2 = UILabel()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.backgroundColor = .gray500
        self.makeCornerRound(radius: 15)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3 // 그림자 투명도
        self.layer.shadowOffset = CGSize(width: 3, height: 3) // 그림자 위치
        self.layer.shadowRadius = 3 // 그림자 반경
        self.layer.masksToBounds = false
        
        lockImage.do {
            $0.image = ImageLiterals.Home.notification_empty
        }
        
        notiLabel1.do {
            $0.text = I18N.Home.notNotiDescription1
            $0.font = .fontGuide(.body3_reg)
            $0.textColor = .white000
        }
        
        notiLabel2.do {
            $0.text = I18N.Home.notNotiDescription2
            $0.font = .fontGuide(.body3_reg)
            $0.textColor = .white000
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.addSubviews(lockImage, notiLabel1, notiLabel2)
        
        lockImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(18)
        }
        
        notiLabel1.snp.makeConstraints {
            $0.top.equalTo(lockImage.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(18)
        }
        
        notiLabel2.snp.makeConstraints {
            $0.top.equalTo(notiLabel1.snp.bottom).offset(8)
            $0.leading.equalTo(notiLabel1)
        }
    }
}
