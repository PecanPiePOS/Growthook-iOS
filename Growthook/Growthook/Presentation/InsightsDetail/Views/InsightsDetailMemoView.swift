//
//  InsightsDetailMemoView.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

final class InsightsDetailMemoView: BaseView {

    private let memoContent = UILabel()
    private let referenceTitle = UILabel()
    private let referenceUrlTitle = UILabel()
    private let dividerView = UIView()

    override func setStyles() {
        backgroundColor = .clear
        
        memoContent.do {
            $0.numberOfLines = 0
            $0.textColor = .white000
            $0.font = .fontGuide(.body3_reg)
        }
        
        referenceTitle.do {
            $0.numberOfLines = 1
            $0.font = .fontGuide(.detail2_bold)
            $0.textColor = .gray200
            $0.backgroundColor = .gray500
            $0.makeCornerRound(radius: 5)
        }
        
        referenceUrlTitle.do {
            $0.numberOfLines = 1
            $0.font = .fontGuide(.detail2_reg)
            $0.textColor = .gray200
            $0.backgroundColor = .gray500
            $0.roundCorners(cornerRadius: 5, maskedCorners: [.bottomRight, .topRight])
        }
        
        dividerView.do {
            $0.backgroundColor = .gray200
            $0.makeCornerRound(radius: 5)
        }
    }
 
    override func setLayout() {
        self.addSubviews(
            memoContent, referenceUrlTitle, referenceTitle,
            dividerView
        )
        
        memoContent.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.lessThanOrEqualTo(240)
        }
        
        referenceUrlTitle.snp.makeConstraints {
            $0.top.equalTo(memoContent.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.lessThanOrEqualTo(100)
            $0.height.equalTo(26)
        }
        
        referenceTitle.snp.makeConstraints {
            $0.trailing.equalTo(referenceUrlTitle.snp.leading)
            $0.centerY.equalTo(referenceUrlTitle)
            $0.width.lessThanOrEqualTo(120)
            $0.height.equalTo(26)
        }
    
        dividerView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(14)
            $0.centerY.equalTo(referenceTitle)
            $0.centerX.equalTo(referenceTitle.snp.trailing)
        }
    }
}

extension InsightsDetailMemoView {
    
    func setMemoContent(with content: String?) {
        memoContent.text = content
    }
    
    func setReferenceContent(reference: String, url: String?) {
        referenceTitle.text = "   " + reference + "   "
        if let urlData = url {
            referenceUrlTitle.text = "   " + urlData + "   "
        } else {
            dividerView.removeFromSuperview()
        }
    }
}
