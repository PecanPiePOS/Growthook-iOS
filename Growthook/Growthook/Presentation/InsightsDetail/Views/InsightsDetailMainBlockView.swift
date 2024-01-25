//
//  InsightsDetailMainBlockView.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/15/24.
//

import UIKit

final class InsightsDetailMainBlockView: BaseView {

    private let nameLabel = UILabel()
    private let insightLabel = UILabel()
    private let dateLabel = UILabel()
    private let verticalDividerView = UIView()
    private let remainingDateLabel = UILabel()
    private let dividerView = UILabel()

    override func setStyles() {
        backgroundColor = .gray700
        
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
            $0.numberOfLines = 1
        }
        
        dateLabel.do {
            $0.textColor = .gray200
            $0.font = .fontGuide(.detail2_bold)
        }
        
        verticalDividerView.do {
            $0.backgroundColor = .gray300
        }
        
        remainingDateLabel.do {
            $0.textColor = .red200
            $0.font = .fontGuide(.detail2_bold)
        }
        
        dividerView.do {
            $0.backgroundColor = .gray400
        }
    }
    
    override func setLayout() {
        addSubviews(
            nameLabel, insightLabel, dateLabel,
            verticalDividerView, remainingDateLabel, dividerView
        )
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(18)
            $0.height.equalTo(22)
        }
        
        insightLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(18)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(insightLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(18)
        }
        
        verticalDividerView.snp.makeConstraints {
            $0.leading.equalTo(dateLabel.snp.trailing).offset(10)
            $0.width.equalTo(1)
            $0.height.equalTo(12)
            $0.centerY.equalTo(dateLabel)
        }
        
        remainingDateLabel.snp.makeConstraints {
            $0.leading.equalTo(verticalDividerView.snp.trailing).offset(10)
            $0.centerY.equalTo(dateLabel)
        }
        
        dividerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.top.equalTo(dateLabel.snp.bottom).offset(12)
            $0.height.equalTo(2)
        }
    }
}

extension InsightsDetailMainBlockView: InsightBoxViewType {
    func bindInsight(model: ActionPlanResponse) {
        nameLabel.text = "" + model.caveName + "   "
        insightLabel.text = model.insight
        dateLabel.text = model.lockDate
        if model.remainingDays > 0 {
            remainingDateLabel.text = "D-" + String(model.remainingDays)
        } else {
            remainingDateLabel.removeFromSuperview()
            verticalDividerView.removeFromSuperview()
        }
    }
    
    var moreButton: UIButton { return UIButton() }
    
    func showDetail() {}
    func fold() {}
}
