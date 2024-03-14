//
//  EmptyView.swift
//  Growthook
//
//  Created by 천성우 on 3/10/24.
//


import UIKit

import SnapKit
import Then

enum emptyViewType {
    case inprogress
    case complete
}

final class EmptyView: BaseView {
    
    // MARK: - UI Components

    let emptyImageView = UIImageView()
    let emptyLabel = UILabel()
    
    // MARK: - Properties
    
    var emptyType: emptyViewType
    
    
    // MARK: - Initializer
    
    init(frame: CGRect, emptyType: emptyViewType) {
        self.emptyType = emptyType
        super.init(frame: frame)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        backgroundColor = .gray700
        
        switch emptyType {
        case .inprogress:
            emptyLabel.do {
                $0.text = "아직 작성된 할 일이 없어요"
                $0.textColor = .gray200
                $0.font = .fontGuide(.body1_reg)
            }
        case .complete:
            emptyLabel.do {
                $0.text = "아직 수확한 쑥이 없어요"
                $0.textColor = .gray200
                $0.font = .fontGuide(.body1_reg)
            }
        }
        
        emptyImageView.do {
            $0.image = ImageLiterals.Component.ic_largethook_mono
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        addSubviews(emptyImageView, emptyLabel)
        
        emptyImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(SizeLiterals.Screen.screenHeight * 0.1108)
            $0.centerX.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(SizeLiterals.Screen.screenHeight * 0.0246)
            $0.centerX.equalToSuperview()
        }
        
    }
    
    // MARK: - Methods
        

    
    // MARK: - @objc Methods
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
