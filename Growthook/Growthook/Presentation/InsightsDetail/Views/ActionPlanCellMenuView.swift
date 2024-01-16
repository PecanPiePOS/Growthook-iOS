//
//  ActionPlanCellMenuView.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/15/24.
//

import UIKit

import RxCocoa
import RxSwift

final class ActionPlanCellMenuView: BaseView {

    private let editButton = UIButton()
    private let deleteButton = UIButton()
    private(set) var actionPlanId = 0
    
    lazy var rxEditButtonControl: ControlEvent<Void> = editButton.rx.tap
    lazy var rxDeleteButtonControl: ControlEvent<Void> = deleteButton.rx.tap
    
    override func setStyles() {
        makeCornerRound(radius: 4)
        backgroundColor = .gray400
        
        editButton.do {
            $0.setTitle("수정", for: .normal)
            $0.setTitleColor(.white000, for: .normal)
            $0.titleLabel?.font = .fontGuide(.body3_reg)
        }
        
        deleteButton.do {
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(.white000, for: .normal)
            $0.titleLabel?.font = .fontGuide(.body3_reg)
        }
    }
    
    override func setLayout() {
        addSubviews(editButton, deleteButton)
        
        editButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalTo(self.snp.centerY)
            $0.horizontalEdges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
    }
}

extension ActionPlanCellMenuView {
    
    func setActionId(_ id: Int) {
        self.actionPlanId = id
    }
}
