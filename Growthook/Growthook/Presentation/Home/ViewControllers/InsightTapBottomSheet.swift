//
//  InsightTapBottomSheet.swift
//  Growthook
//
//  Created by KJ on 11/20/23.
//

import UIKit

import Moya
import SnapKit
import Then
import RxCocoa
import RxSwift

final class InsightTapBottomSheet: BaseViewController {

    // MARK: - UI Components
    
    private let buttonView = UIView()
    private let moveButton = UIButton()
    private let deleteButton = UIButton()
    private let removeInsightAlertView = UIView()
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    var onDismiss: (() -> Void)?
    var indexPath: IndexPath? = nil
    
    // MARK: - Initializer
    
    init(viewModel: HomeViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        setTapScreen()
        bindViewModel()
        setStyles()
        setLayout()
        setDelegates()
    }
    
    override func bindViewModel() {
        moveButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.inputs.moveMenuTap()
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.presentToCaveList
            .subscribe(onNext: { [weak self] in
                self?.presentToCaveListVC()
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.inputs.removeMenuTap()
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.removeInsightAlertView
            .subscribe(onNext: { [weak self] in
                self?.addRemoveInsightAlert()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        view.backgroundColor = .clear
        
        buttonView.do {
            $0.backgroundColor = .green400
        }
        
        moveButton.do {
            $0.setImage(ImageLiterals.Home.btn_move, for: .normal)
        }
        
        deleteButton.do {
            $0.setImage(ImageLiterals.Home.btn_delete, for: .normal)
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        view.addSubviews(buttonView)
        buttonView.addSubviews(moveButton, deleteButton)
        
        buttonView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 84 / 812)
        }
        
        moveButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(SizeLiterals.Screen.screenWidth * 70 / 375)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(moveButton)
            $0.trailing.equalToSuperview().inset(SizeLiterals.Screen.screenWidth * 70 / 375)
        }
    }
    
    // MARK: - Methods
    
    override func setDelegates() {
        self.presentationController?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsightTapBottomSheet: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss?()
    }
}

extension InsightTapBottomSheet {
    
    // MARK: - Methods
    
    private func presentToCaveListVC() {
        let caveListVC = CaveListHalfModal(viewModel: viewModel)
        caveListVC.modalPresentationStyle = .pageSheet
        let customDetentIdentifier = UISheetPresentationController.Detent.Identifier(I18N.Component.Identifier.customDetent)
        let customDetent = UISheetPresentationController.Detent.custom(identifier: customDetentIdentifier) { (_) in
            return SizeLiterals.Screen.screenHeight * 420 / 812
        }
        
        if let sheet = caveListVC.sheetPresentationController {
            sheet.detents = [customDetent]
            sheet.preferredCornerRadius = 15
            sheet.prefersGrabberVisible = true
            sheet.delegate = caveListVC as? any UISheetPresentationControllerDelegate
        }
        
        caveListVC.indexPath = self.indexPath
        present(caveListVC, animated: true)
    }
    
    private func addRemoveInsightAlert() {
        let removeInsightAlertVC = RemoveInsightAlertViewController(viewModel: viewModel)
        removeInsightAlertVC.modalPresentationStyle = .overFullScreen
        self.present(removeInsightAlertVC, animated: false, completion: nil)
    }
    
    private func setTapScreen() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - @objc Methods
    
    @objc
    private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: self.view)
        if !buttonView.frame.contains(touchLocation) {
            guard let indexPath = self.indexPath else { return }
            viewModel.inputs.dismissInsightTap(at: indexPath)
            dismiss(animated: true)
        }
    }
}
