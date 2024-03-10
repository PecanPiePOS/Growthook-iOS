//
//  ActionListTableViewCell.swift
//  Growthook
//
//  Created by 천성우 on 11/18/23.
//

import UIKit

import Moya
import RxCocoa
import RxSwift
import SnapKit
import Then

final class ActionListTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    let scrapButton = UIButton()
    let actionTitleLabel = UILabel()
    let seedButton = UIButton()
    let completButton = UIButton()
    private let topBorder = UIView()
    private let bottomBorder = UIView()
    
    // MARK: - Property
    
    var actionPlanId: Int = 0
    var seedId: Int = 0
    var isScraped: Bool = false
    
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
        setStyles()
        selectedBackgroundView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ActionListTableViewCell {
    
    // MARK: - UI Components Property
    
    private func setStyles() {
        self.backgroundColor = .gray700
        
        scrapButton.do {
            $0.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
        }
        
        actionTitleLabel.do {
            $0.font = .fontGuide(.body3_bold)
            $0.textColor = .white000
            $0.numberOfLines = 2
        }
        
        seedButton.do {
            $0.setTitle("씨앗 보기", for: .normal)
            $0.setTitleColor(.white000, for: .normal)
            $0.titleLabel?.font = .fontGuide(.detail1_bold)
            $0.backgroundColor = .gray500
            $0.layer.cornerRadius = 10
        }
        
        completButton.do {
            $0.setTitle("수확하기", for: .normal)
            $0.setTitleColor(.white000, for: .normal)
            $0.titleLabel?.font = .fontGuide(.detail1_bold)
            $0.backgroundColor = .green400
            $0.layer.cornerRadius = 10
            $0.isUserInteractionEnabled = true
        }
        
        topBorder.do {
            $0.backgroundColor = .gray400
        }
        
        bottomBorder.do {
            $0.backgroundColor = .gray400
        }
    }
    
    
    // MARK: - Layout Helper
    
    func setLayout() {
        contentView.addSubviews(scrapButton, actionTitleLabel, seedButton, completButton, topBorder, bottomBorder)
        
        scrapButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalToSuperview().offset(4)
        }
        
        actionTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(scrapButton.snp.trailing)
            $0.width.equalTo(306)
        }
        
        seedButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(164)
            $0.height.equalTo(40)
        }
        
        completButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(17)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(164)
            $0.height.equalTo(40)
        }
        
        topBorder.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        bottomBorder.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    
    // MARK: - Configure
    
    func configure(_ model: ActionListDoingResponse) {
        switch model.isScraped {
        case false:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
        case true:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
        }
        actionTitleLabel.text = model.content
        actionPlanId = model.actionPlanId
        seedId = model.seedId
        isScraped = model.isScraped
    }
}
