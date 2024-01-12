//
//  MyPageUserInfoBlockView.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import UIKit

final class MyPageUserInfoBlockView: BaseView {

    private let titleLabel = UILabel()
    private let userInformationLabel = UILabel()
    private let dividerLine = UIView()

    override func setStyles() {
        backgroundColor = .clear
        
        titleLabel.do {
            $0.font = .fontGuide(.head4)
            $0.textColor = .green400
        }
        
        userInformationLabel.do {
            $0.font = .fontGuide(.body3_bold)
            $0.textColor = .white000
        }
        
        dividerLine.do {
            $0.backgroundColor = .gray100
        }
    }
    
    override func setLayout() {
        addSubviews(titleLabel, userInformationLabel, dividerLine)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        userInformationLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(21)
            $0.leading.equalToSuperview()
        }
        
        dividerLine.snp.makeConstraints {
            $0.top.equalTo(userInformationLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

extension MyPageUserInfoBlockView {
    
    func setTitle(with title: String) {
        titleLabel.text = title
    }
    
    func setInformation(with info: String) {
        userInformationLabel.text = info
    }
}
