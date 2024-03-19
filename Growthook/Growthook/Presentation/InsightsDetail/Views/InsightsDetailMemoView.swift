//
//  InsightsDetailMemoView.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

final class InsightsDetailMemoView: BaseView {
    
    private let memoContent = UILabel()
    let referenceStackView = UIStackView()
    private let referenceTitle = UILabel()
    let referenceUrlTitle = UILabel()
    private let dividerView = UIView()

    override func setStyles() {
        backgroundColor = .clear
        
        memoContent.do {
            $0.numberOfLines = 0
            $0.textColor = .white000
            $0.font = .fontGuide(.body3_reg)
        }
    
        referenceStackView.do {
            $0.spacing = 10
            $0.isLayoutMarginsRelativeArrangement = true
            $0.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            $0.backgroundColor = .gray500
            $0.makeCornerRound(radius: 5)

        }
        
        referenceTitle.do {
            $0.numberOfLines = 1
            $0.font = .fontGuide(.detail2_bold)
            $0.textColor = .gray200
        }
        
        referenceUrlTitle.do {
            $0.numberOfLines = 1
            $0.font = .fontGuide(.detail2_reg)
            $0.textColor = .gray200
        }
        
        dividerView.do {
            $0.backgroundColor = .gray200
            $0.makeCornerRound(radius: 5)
        }
    }
 
    override func setLayout() {
        self.addSubviews(memoContent, referenceStackView)
        
        [referenceTitle, dividerView, referenceUrlTitle].forEach {
            referenceStackView.addArrangedSubview($0)
        }
        
        memoContent.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(4)
            $0.height.lessThanOrEqualTo(240)
        }
        
        referenceStackView.snp.makeConstraints {
            $0.top.equalTo(memoContent.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().inset(4)
            $0.bottom.equalToSuperview()
            $0.width.lessThanOrEqualTo(SizeLiterals.Screen.screenWidth - 44)
            $0.height.equalTo(26)
        }
        
        referenceTitle.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(120)
            $0.height.equalTo(26)
        }
    
        dividerView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(16)
        }
    }
}

extension InsightsDetailMemoView {
    
    func setMemoContent(with content: String?) {
        memoContent.text = content
    }
    
    func setReferenceContent(reference: String?, url: String?) {
        referenceTitle.text = reference
        referenceUrlTitle.text = url
        if reference == nil && url == nil {
            referenceStackView.removeFromSuperview()
            referenceTitle.removeFromSuperview()
            referenceUrlTitle.removeFromSuperview()
            dividerView.removeFromSuperview()
        } else if reference == nil || url == nil {
            dividerView.removeFromSuperview()
        }
    }
}
