//
//  CaveChangeViewController.swift
//  Growthook
//
//  Created by KJ on 1/14/24.
//

import UIKit

import Moya
import SnapKit
import Then
import RxCocoa
import RxSwift

final class ChangeCaveViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let caveChagneView = ChangeCaveView()
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        self.view.backgroundColor = .clear
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        self.view.addSubviews(caveChagneView)
        
        caveChagneView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
