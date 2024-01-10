//
//  CaveDetailMenuModal.swift
//  Growthook
//
//  Created by KJ on 1/10/24.
//

import UIKit

import Moya
import SnapKit
import Then
import RxCocoa
import RxSwift

final class CaveDetailMenuBottomSheet: BaseViewController {

    // MARK: - UI Components
    
    private lazy var changeCaveButton = CaveMenuButton(buttonTitle: "수정하기", buttonImage: ImageLiterals.Menu.ic_change)
    private lazy var deleteCaveButton = CaveMenuButton(buttonTitle: "삭제하기", buttonImage: ImageLiterals.Menu.ic_delete)
    
    // MARK: - UI Components Property
    
    override func setStyles() {
    
        view.backgroundColor = .gray400
        
        changeCaveButton.do {
            $0.backgroundColor = .gray500
            $0.makeCornerRound(radius: 10)
        }
        
        deleteCaveButton.do {
            $0.backgroundColor = .gray500
            $0.makeCornerRound(radius: 10)
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        view.addSubviews(changeCaveButton, deleteCaveButton)
        
        changeCaveButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(SizeLiterals.Screen.screenHeight * 40 / 812)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
        }
        
        deleteCaveButton.snp.makeConstraints {
            $0.top.equalTo(changeCaveButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
        }
    }
}
