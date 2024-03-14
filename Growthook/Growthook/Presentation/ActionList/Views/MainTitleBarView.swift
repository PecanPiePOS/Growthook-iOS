//
//  MainTitleBarView.swift
//  Growthook
//
//  Created by 천성우 on 11/13/23.
//

import UIKit

import SnapKit
import Then

final class MainTitleBarView: BaseView {
    
    // MARK: - UI Components
    
    let mainTitleLabel = UILabel()
    let percentView = UIView()
    let percentBar = UIView()
    let percentGauge = UIView()
    let leepImage = UIImageView()
    let percentLabel = UILabel()
    
    // MARK: - Properties
    
    var percent: Double = 0.0
    var standardPercent: Double = SizeLiterals.Screen.screenWidth * 0.8053
    var widthConstraint: Constraint?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles(){
        mainTitleLabel.do {
            $0.font = .fontGuide(.head1)
            $0.textColor = .white000
        }
        
        percentView.do {
            $0.backgroundColor = .gray900
            $0.layer.cornerRadius = 6
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.green600.cgColor
        }
        
        percentBar.do {
            $0.backgroundColor = .gray600
            $0.layer.cornerRadius = 6
        }
        
        percentGauge.do {
            $0.backgroundColor = .green400
            $0.layer.cornerRadius = 6
        }
                
        leepImage.do {
            $0.image = ImageLiterals.Component.ic_halfthook
        }
        
        percentLabel.do {
            $0.font = .fontGuide(.head3)
            $0.textColor = .white000
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        addSubviews(mainTitleLabel, percentView)
        percentView.addSubviews(leepImage, percentLabel, percentBar)
        percentBar.addSubviews(percentGauge)
        
        leepImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(SizeLiterals.Screen.screenHeight * 0.0234)
            $0.trailing.equalToSuperview().offset(-SizeLiterals.Screen.screenWidth * 0.048)
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.24)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.0703)
        }
        
        percentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(SizeLiterals.Screen.screenHeight * 0.0512)
            $0.leading.equalToSuperview().offset(SizeLiterals.Screen.screenWidth * 0.048)
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.2627)
        }
        
        percentBar.snp.makeConstraints {
            $0.top.equalTo(leepImage.snp.bottom)
            $0.leading.equalToSuperview().offset(SizeLiterals.Screen.screenWidth * 0.048)
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.8053)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.0123)
        }
        
        percentGauge.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            widthConstraint = $0.width.equalTo(0).constraint
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.0123)
        }
        
        mainTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(18)
        }
        
        percentView.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(SizeLiterals.Screen.screenWidth * 0.048)
            $0.width.equalTo(SizeLiterals.Screen.screenWidth * 0.904)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 0.1307)
        }
    }
    
    // MARK: - Methods
        
    func setTitleText(_ text: String) {
         mainTitleLabel.text = "\(text)님의 할 일"
     }
    
    func setPercentText(_ percent: String) {
        percentLabel.text = "\(percent)% 달성!"
        self.percent = Double(percent)! * 0.01
        setPercentGauge(percent: self.percent)
    }
    
    func setPercentGauge(percent: Double) {
        widthConstraint?.update(offset: percent * standardPercent)
    }
    
    // MARK: - @objc Methods
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
