//
//  InsigthDetailActionPlanSheetViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

enum ActionPlanSheetPurpose {
    case create
    case edit(actionPlanId: Int)
    
    var title: String {
        switch self {
        case .create:
            return "액션 플랜 추가"
        case .edit:
            return "액션 플랜 수정"
        }
    }
}

final class InsigthDetailActionPlanSheetViewController: BaseViewController {

    private let titleLabel = UILabel()
    private let exitButton = UIButton()
    private let textView = TextViewBlockWithTitle(placeholder: I18N.ActionList.insightDetailPlaceholder, maxLength: 40)
    private let doneButton = UIButton()
    private let loadingView = FullCoverLoadingView()
    
    private var disposeBag = DisposeBag()
    private var savedContent: String?
    private let originalContent: String?
    private let isButtonEnabled = BehaviorRelay(value: false)
    private var purpose: ActionPlanSheetPurpose
    private let viewModel: InsightsDetailViewModel
    private var newContentText: String = ""
    private var keyboardHeight: CGFloat = 0
    private var keyboardDuration: CGFloat = 0
    private var isFirstPresented = true
    
    init(purpose: ActionPlanSheetPurpose, viewModel: InsightsDetailViewModel, originalContentText: String? = nil) {
        self.viewModel = viewModel
        self.savedContent = originalContentText
        self.originalContent = originalContentText
        self.purpose = purpose
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let text = savedContent {
            textView.textViewBlock.text = text
        }
        setDataBind()
        setNotificationForKeyboardHeight()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotification()
        reloadIfNeeded()
        disposeBag = DisposeBag()
    }
    
    override func setStyles() {
        view.backgroundColor = .gray600
        
        titleLabel.do {
            $0.font = .fontGuide(.body1_reg)
            $0.textColor = .white000
            $0.text = purpose.title
        }
        
        exitButton.do {
            let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            $0.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
            $0.tintColor = .white000
        }
        
        doneButton.do {
            $0.setTitle("완료", for: .normal)
            $0.makeCornerRound(radius: 10)
        }
        
        loadingView.do {
            $0.isHidden = true
        }
    }
    
    override func setLayout() {
        view.addSubviews(
            titleLabel, exitButton, textView,
            doneButton, loadingView
        )
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(21)
        }
        
        exitButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(18)
            $0.size.equalTo(30)
        }
        
        textView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(110)
            $0.top.equalToSuperview().inset(80)
        }
        
        doneButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(40)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsigthDetailActionPlanSheetViewController {
    
    private func setDataBind() {
        textView.textViewBlock.rx.text
            .bind { [weak self] text in
                guard let self else { return }
                guard let text else { return }
                self.newContentText = text
                if text == I18N.ActionList.insightDetailPlaceholder {
                    self.isButtonEnabled.accept(false)
                } else if text.isEmpty {
                    self.isButtonEnabled.accept(false)
                } else {
                    self.isButtonEnabled.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        textView.textViewBlock.rxEditingAction
            .bind { [weak self] events in
                guard let self else { return }
                switch events {
                case .editingDidBegin:
                    self.moveButtonUp()
                case .editingDidEnd:
                    self.moveButtonDown()
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        isButtonEnabled
            .bind { [weak self] enabled in
                guard let self else { return }
                self.doneButton.isEnabled = enabled
                self.doneButton.backgroundColor = enabled ? .green400: .gray500
                self.doneButton.setTitleColor(
                    enabled ? .white000: .gray300,
                    for: .normal
                )
            }
            .disposed(by: disposeBag)
        
        exitButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.loadingView.isHidden = false
                switch self.purpose {
                case .create:
                    self.viewModel.inputs.addSingleNewAction(newActionPlanText: self.newContentText) { success in
                        switch success {
                        case true:
                            self.dismiss(animated: true)
                        case false:
                            self.loadingView.isHidden = true
                            self.view.showToast(message: "실패했어요 다시 시도해주세요", success: false)
                        }
                    }
                    self.view.endEditing(true)
                case .edit(let actionPlanId):
                    if newContentText == originalContent {
                        self.dismiss(animated: true)
                        return
                    }
                    self.viewModel.inputs.editActionPlan(actionPlanId: actionPlanId, editedActionPlanText: self.newContentText) { success in
                        switch success {
                        case true:
                            self.dismiss(animated: true)
                        case false:
                            self.loadingView.isHidden = true
                            self.view.showToast(message: "실패했어요 다시 시도해주세요", success: false)
                        }
                        self.view.endEditing(true)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.actionPlanPatchStatus
            .bind { [weak self] status in
                guard let self else { return }
                switch status {
                case .normal:
                    break
                case .error:
                    self.loadingView.isHidden = true
                    self.view.showToast(message: "재시도해주세요", success: false)
                case .done:
                    self.dismiss(animated: true)
                    self.viewModel.reloadActionPlan()
                }
            }
            .disposed(by: disposeBag)
    }
}

extension InsigthDetailActionPlanSheetViewController {
    
    private func moveButtonUp() {
        doneButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(20+keyboardHeight)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        UIView.animate(withDuration: self.keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func moveButtonDown() {
        doneButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(40)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        UIView.animate(withDuration: self.keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func reloadIfNeeded() {
        var isEdited: Bool = true

        if let originalContent {
            if originalContent == newContentText {
                isEdited = false
            } else {
                isEdited = true
            }
        }
        
        if !newContentText.isEmpty || isEdited != false {
            viewModel.inputs.reloadActionPlan()
        }
    }
    
    private func setNotificationForKeyboardHeight() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, 
            let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            let keyboardHeight = keyboardSize.height
            self.keyboardHeight = keyboardHeight
            self.keyboardDuration = keyboardDuration
            if self.isFirstPresented != false {
                moveButtonUp()
                self.isFirstPresented = false
            }
        }
    }
}
