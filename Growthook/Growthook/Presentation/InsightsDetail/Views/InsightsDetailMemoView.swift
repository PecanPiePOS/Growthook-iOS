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
    private let referenceStackView = UIStackView()

    override func setStyles() {
        backgroundColor = .clear
        
        memoContent.do {
            $0.numberOfLines = 0
            $0.textColor = .white000
            $0.font = .fontGuide(.body3_reg)
        }
        
        referenceStackView.do {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.makeCornerRound(radius: 5)
            $0.backgroundColor = .gray500
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
        }
    }
 
    override func setLayout() {
        self.addSubviews(memoContent, referenceStackView)
        referenceStackView.addArrangedSubviews(
            referenceTitle, dividerView, referenceUrlTitle
        )
        
        memoContent.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        referenceStackView.snp.makeConstraints {
            $0.top.equalTo(memoContent.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(26)
            $0.width.lessThanOrEqualTo(frame.size.width-50)
            $0.bottom.equalToSuperview()
        }
    
        dividerView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(14)
        }
    }
}

extension InsightsDetailMemoView {
    
    func setMemoContent(with content: String) {
        memoContent.text = content
    }
    
    func setReferenceContent(reference: String, url: String?) {
        referenceTitle.text = reference
        referenceUrlTitle.text = url
        if url == nil {
            dividerView.removeFromSuperview()
        }
    }
}
