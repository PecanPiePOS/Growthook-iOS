//
//  CaveEmptyView.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/14/24.
//

import UIKit

import SnapKit
import Then

final class CaveEmptyView: BaseView {
    
    // MARK: - UI Components
    
    let navigationBar = CustomNavigationBar()
    private let caveInfoView = CaveInfoView()
    private let emptySeedView = EmptySeedView()
    let plantSeedButton = BottomCTAButton(type: .plantSeed)
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        navigationBar.isCloseButtonIncluded = true
        navigationBar.backgroundColor = .gray600
        caveInfoView.backgroundColor = .gray600
        self.backgroundColor = .gray600
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        self.addSubviews(navigationBar, caveInfoView, emptySeedView, plantSeedButton)
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        caveInfoView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(emptySeedView.snp.top)
        }
        
        emptySeedView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(236)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        plantSeedButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
        }
    }
}

extension CaveEmptyView {
    
    func bindModel(model: CaveDetailModel) {
        caveInfoView.bindModel(model: model)
    }
}
