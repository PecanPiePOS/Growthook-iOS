//
//  FullCoverLoadingView.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import UIKit

class FullCoverLoadingView: BaseView {

    private let indicatorView = UIActivityIndicatorView()

    override func setStyles() {
        backgroundColor = .black.withAlphaComponent(0.2)
        
        indicatorView.color = .green400
        indicatorView.style = .large
        indicatorView.startAnimating()
    }
    
    override func setLayout() {
        addSubview(indicatorView)
        
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
