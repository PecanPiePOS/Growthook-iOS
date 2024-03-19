//
//  InsightDetailMenuViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

protocol InsightMenuDelegate: AnyObject {
    func pushToEditView()
    func dismissAndShowAlertView()
}

final class InsightDetailMenuViewController: BaseViewController {
    
    weak var delegate: InsightMenuDelegate?
    
    private let relocateButton = CaveMenuButton(buttonTitle: "이동하기", buttonImage: ImageLiterals.Insight.moveButton, textColor: .white000)
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
                dismiss(animated: true)
                self.delegate?.pushToEditView()
            }
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.dismissAndShowDeleteAlertView()
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
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 101 / 812)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(17)
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
        }
        
        relocateButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
        }
        
        editButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 50 / 812)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsightDetailMenuViewController: CaveDismissDelegate {

    private func showCaveSheetView() {
        viewModel.inputs.getAllCaves()
        let caveBottomSheetViewController = InsightDetailCaveViewController(viewModel: self.viewModel)
        caveBottomSheetViewController.modalPresentationStyle = .pageSheet
        caveBottomSheetViewController.delegate = self
        if let sheet = caveBottomSheetViewController.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in return 400 })
            ]
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = true
        }
        present(caveBottomSheetViewController, animated: true)
    }
    
    func dismissPresentingView() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
            self.dismiss(animated: true)
        }
    }
    
    private func dismissAndShowDeleteAlertView() {
        delegate?.dismissAndShowAlertView()
        dismiss(animated: true)
    }
}
