//
//  InsightDetailMenuViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

final class InsightDetailMenuViewController: BaseViewController {

    private let relocateButton = CaveMenuButton(buttonTitle: "이동하기", buttonImage: ImageLiterals.Home.btn_move, textColor: .white000)
    private let editButton = CaveMenuButton(buttonTitle: "수정하기", buttonImage: ImageLiterals.Menu.ic_change, textColor: .white000)
    private let buttonStackView = UIStackView()
    
    private let deleteButton = CaveMenuButton(buttonTitle: "삭제하기", buttonImage: ImageLiterals.Menu.ic_delete, textColor: .red200)
    
    private let disposeBag = DisposeBag()
    private let viewModel: InsightsDetailViewModel
    
    init(viewModel: InsightsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func bindViewModel() {
        relocateButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.showCaveSheetView()
            }
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.pushToEditSeedView()
            }
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.showDeletePopView()
            }
            .disposed(by: disposeBag)
    }
    
    override func setStyles() {
        view.backgroundColor = .gray400
        relocateButton.backgroundColor = .gray500
        editButton.backgroundColor = .gray500
        
        deleteButton.do {
            $0.backgroundColor = .gray500
            $0.makeCornerRound(radius: 10)
        }
        
        buttonStackView.do {
            $0.axis = .vertical
            $0.makeCornerRound(radius: 10)
            $0.spacing = 1
            $0.distribution = .fillEqually
        }
    }
    
    override func setLayout() {
        view.addSubviews(buttonStackView, deleteButton)
        buttonStackView.addArrangedSubviews(relocateButton, editButton)
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.horizontalEdges.equalToSuperview().inset(17)
            $0.height.equalTo(101)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(17)
            $0.height.equalTo(50)
        }
        
        relocateButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
        }
        
        editButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsightDetailMenuViewController {
    
    private func showCaveSheetView() {
        
    }
    
    private func pushToEditSeedView() {
        
    }
    
    private func showDeletePopView() {
        
    }
}
