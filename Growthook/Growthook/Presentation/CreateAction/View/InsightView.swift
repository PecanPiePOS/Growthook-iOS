//
//  InsightView.swift
//  Growthook
//
//  Created by Minjoo Kim on 11/22/23.
//

import UIKit

import SnapKit
import Then

final class InsightView: BaseView, InsightBoxViewType {
    
    private let nameLabel = UILabel()
    private let insightLabel = UILabel()
    private let divisionLabel = UILabel()
    let moreButton = UIButton()
    private let dateLabel = UILabel()
    private let verticalDividerView = UILabel()
    private let dDayLabel = UILabel()
    private let memoScrollView = UIScrollView()
    private let memoLabel = UILabel()
    let scrapButton = UIButton()
    private let emptyMemoView = UIView()
    private let emptyMemoImageView = UIImageView()
    private let emptyMemoLabel = UILabel()
        
    private var isScrap = false
    
    override func setStyles() {
        self.do {
            $0.backgroundColor = .gray600
            $0.roundCorners(cornerRadius: 20, maskedCorners: [.bottomLeft, .bottomRight])
        }
        
        nameLabel.do {
            $0.font = .fontGuide(.detail1_bold)
            $0.backgroundColor = .green100
            $0.textColor = .green600
            $0.textAlignment = .center
            $0.makeCornerRound(radius: 4)
        }
        
        insightLabel.do {
            $0.font = .fontGuide(.body2_bold)
            $0.textColor = .white000
        }
        
        divisionLabel.do {
            $0.backgroundColor = .gray400
        }
        
        moreButton.do {
            $0.setImage(ImageLiterals.ActionPlan.btn_more, for: .normal)
        }
        
        dateLabel.do {
            $0.font = .fontGuide(.detail2_bold)
            $0.textColor = .gray200
            $0.isHidden = true
        }
        
        verticalDividerView.do {
            $0.backgroundColor = .gray300
            $0.isHidden = true
        }
        
        dDayLabel.do {
            $0.font = .fontGuide(.detail2_bold)
            $0.textColor = .red200
            $0.isHidden = true
        }
        
        memoScrollView.do {
            $0.contentInsetAdjustmentBehavior = .never
        }
        
        memoLabel.do {
            $0.font = .fontGuide(.body3_reg)
            $0.textColor = .white000
            $0.numberOfLines = 0
            $0.isHidden = true
        }
        
        scrapButton.do {
            $0.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
            $0.isHidden = true
        }
        
        emptyMemoView.do {
            $0.isHidden = true
        }
        
        emptyMemoImageView.do {
            $0.image = ImageLiterals.Component.ic_largethook_mono
        }
        
        emptyMemoLabel.do {
            $0.text = "작성된 메모가 없어요"
            $0.font = .fontGuide(.detail1_reg)
            $0.textColor = .gray200
        }
    }
    
    override func setLayout() {
        self.addSubviews(nameLabel, insightLabel, divisionLabel, dateLabel, verticalDividerView, dDayLabel, memoScrollView, moreButton, scrapButton, emptyMemoView)
        memoScrollView.addSubview(memoLabel)
        emptyMemoView.addSubviews(emptyMemoImageView, emptyMemoLabel)
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18)
            $0.leading.equalToSuperview().inset(18)
            $0.width.equalTo(36)
            $0.height.equalTo(22)
        }
        
        insightLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(18)
        }
        
        divisionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.bottom.equalToSuperview().inset(38)
            $0.height.equalTo(2)
        }
        
        moreButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(138)
            $0.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(insightLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(18)
        }
        
        verticalDividerView.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel.snp.centerY)
            $0.leading.equalTo(dateLabel.snp.trailing).offset(10)
            $0.width.equalTo(2)
            $0.height.equalTo(14)
        }
        
        dDayLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel.snp.centerY)
            $0.leading.equalTo(verticalDividerView.snp.trailing).offset(10)
        }
        
        memoScrollView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(135)
        }
        
        memoLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(memoScrollView.snp.width)
        }
        
        scrapButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(48)
        }
        
        emptyMemoView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(135)
        }
        
        emptyMemoImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(82)
        }
        
        emptyMemoLabel.snp.makeConstraints {
            $0.top.equalTo(emptyMemoImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
}

extension InsightView {

    func bindInsight(model: ActionPlanResponse) {
        nameLabel.text = model.caveName
        nameLabel.sizeToFit()
        insightLabel.text = model.insight
        dateLabel.text = model.lockDate
        switch model.isScraped {
        case true:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
            isScrap = true
        case false:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
            isScrap = false
        }
        if model.remainingDays > 0 {
            dDayLabel.text = "D-\(model.remainingDays)"
            self.addSubviews(dDayLabel, verticalDividerView)
            
            verticalDividerView.snp.remakeConstraints {
                $0.centerY.equalTo(dateLabel.snp.centerY)
                $0.leading.equalTo(dateLabel.snp.trailing).offset(10)
                $0.width.equalTo(2)
                $0.height.equalTo(14)
            }
            
            dDayLabel.snp.remakeConstraints {
                $0.centerY.equalTo(dateLabel.snp.centerY)
                $0.leading.equalTo(verticalDividerView.snp.trailing).offset(10)
            }
        } else {
            dDayLabel.removeFromSuperview()
            verticalDividerView.removeFromSuperview()
        }
        if model.memo == nil || model.memo == "" || model.memo == "\n" {
            print("?????")
            memoScrollView.removeFromSuperview()
            self.addSubview(emptyMemoView)
        } else {
            print("/////")
            emptyMemoView.removeFromSuperview()
            self.addSubview(memoScrollView)
            memoScrollView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(18)
                $0.horizontalEdges.equalToSuperview().inset(18)
                $0.height.equalTo(135)
            }
            memoLabel.text = model.memo
            memoLabel.setLineSpacing(lineSpacing: 4)
            nameLabel.snp.updateConstraints {
                $0.width.equalTo(nameLabel.frame.width + 14)
            }
        }
    }
    
    func showDetail() {
        self.emptyMemoView.isHidden = false
        self.dateLabel.isHidden = false
        self.verticalDividerView.isHidden = false
        self.dDayLabel.isHidden = false
        self.memoLabel.isHidden = false
        self.emptyMemoView.alpha = 0.0
        self.dateLabel.alpha = 0.0
        self.verticalDividerView.alpha = 0.0
        self.dDayLabel.alpha = 0.0
        self.memoLabel.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.emptyMemoView.alpha = 1.0
            self.dateLabel.alpha = 1.0
            self.verticalDividerView.alpha = 1.0
            self.dDayLabel.alpha = 1.0
            self.memoLabel.alpha = 1.0
            self.divisionLabel.frame.origin.y += 153
            self.moreButton.frame.origin.y += 153
        }, completion: {(isCompleted) in
            self.moreButton.setImage(ImageLiterals.ActionPlan.btn_folding, for: .normal)
        })
    }
    
    func fold() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.emptyMemoView.alpha = 0.0
            self.dateLabel.alpha = 0.0
            self.verticalDividerView.alpha = 0.0
            self.dDayLabel.alpha = 0.0
            self.memoLabel.alpha = 0.0
            self.divisionLabel.frame.origin.y -= 153
            self.moreButton.frame.origin.y -= 153
        }, completion: {(isCompleted) in
            self.emptyMemoView.isHidden = true
            self.moreButton.setImage(ImageLiterals.ActionPlan.btn_more, for: .normal)
            self.dateLabel.isHidden = true
            self.verticalDividerView.isHidden = true
            self.dDayLabel.isHidden = true
            self.memoLabel.isHidden = true
        })
    }
    
    func showScrapButton() {
        scrapButton.isHidden = false
    }
    
    func successScrap() {
        self.isScrap.toggle()
        switch isScrap {
        case true:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
        case false:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
        }
    }
    
    func setScrap(isScraped: Bool) {
        self.isScrap = isScraped
        switch isScraped {
        case true:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
        case false:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
        }
    }
}
