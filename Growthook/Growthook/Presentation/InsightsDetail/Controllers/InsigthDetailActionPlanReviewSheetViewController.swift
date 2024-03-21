//
//  InsigthDetailActionPlanReviewSheetViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

protocol CompleteReviewDelegate: AnyObject {
    func dismissWithAlertView()
}

final class InsigthDetailActionPlanReviewSheetViewController: BaseViewController {

    weak var delegate: CompleteReviewDelegate?
    private let titleLabel = UILabel()
    private let exitButton = UIButton()
    private let textView = TextViewBlockWithTitle(placeholder: I18N.ActionList.insightDetailReviewPlaceholder, maxLength: 300)
    private let saveButton = UIButton()
    private let skipButton = UIButton()
    private let loadingView = FullCoverLoadingView()
    
    private let disposeBag = DisposeBag()
    private let isButtonEnabled = BehaviorRelay(value: false)
    private let viewModel: InsightsDetailViewModel
    private var keyboardHeight: CGFloat = 0
    private var newContentText: String = ""
    private var actionPlanId: Int
    private var keyboardDuration: CGFloat = 0
    private var isFirstPresented = true

    init(viewModel: InsightsDetailViewModel, actionPlanId: Int) {
        self.viewModel = viewModel
        self.actionPlanId = actionPlanId
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDataBind()
        setNotificationForKeyboardHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotification()
    }

    override func setStyles() {
        view.backgroundColor = .gray600
        
        titleLabel.do {
            $0.font = .fontGuide(.body1_reg)
            $0.textColor = .white000
            $0.text = "느낀점 작성"
        }
        
        exitButton.do {
            let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            $0.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
            $0.tintColor = .white000
        }
        
        saveButton.do {
            $0.setTitle("저장하기", for: .normal)
            $0.titleLabel?.font = .fontGuide(.body1_bold)
            $0.makeCornerRound(radius: 10)
        }
        
        skipButton.do {
            $0.setTitle("안 쓸래요", for: .normal)
            $0.setTitleColor(.gray100, for: .normal)
            $0.titleLabel?.font = .fontGuide(.body1_reg)
            $0.backgroundColor = .gray600
        }
        
        loadingView.do {
            $0.isHidden = true
        }
    }
    
    override func setLayout() {
        view.addSubviews(
            titleLabel, exitButton, skipButton,
            saveButton, textView, loadingView
        )
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(21)
        }
        
        exitButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(18)
            $0.size.equalTo(30)
        }
        
        skipButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(40)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
            $0.centerX.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(skipButton.snp.top).offset(-17)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        
        textView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview().inset(80)
            $0.bottom.equalTo(saveButton.snp.top).offset(-80)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsigthDetailActionPlanReviewSheetViewController {
    
    private func setDataBind() {
        textView.textViewBlock.rx.text
            .bind { [weak self] text in
                guard let self else { return }
                guard let text else { return }
                self.newContentText = text
                if text == I18N.ActionList.insightDetailReviewPlaceholder {
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
                self.saveButton.isEnabled = enabled
                self.saveButton.backgroundColor = enabled ? .green400: .gray500
                self.saveButton.setTitleColor(
                    enabled ? .white000: .gray300,
                    for: .normal
                )
            }
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.loadingView.isHidden = false
                self.viewModel.inputs
                    .completeActionPlan(actionPlanId: self.actionPlanId, handler: { success in
                        switch success {
                        case true:
                            if !self.newContentText.isEmpty {
                                self.viewModel.inputs
                                    .postReviewToComplete(review: self.newContentText, actionPlanId: self.actionPlanId) { _ in }
                            }
                            self.delegate?.dismissWithAlertView()
                            self.dismiss(animated: true)
                        case false:
                            self.loadingView.isHidden = true
                            self.view.showToast(message: "실패했어요", success: false)
                        }
                    })
            }
            .disposed(by: disposeBag)
        
        skipButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.loadingView.isHidden = false
                self.viewModel.inputs
                    .completeActionPlan(actionPlanId: self.actionPlanId, handler: { success in
                        switch success {
                        case true:
                            self.delegate?.dismissWithAlertView()
                            self.dismiss(animated: true)
                        case false:
                            self.loadingView.isHidden = true
                            self.view.showToast(message: "실패했어요", success: false)
                        }
                    })
            }
            .disposed(by: disposeBag)
        
        exitButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension InsigthDetailActionPlanReviewSheetViewController {
    
    private func moveButtonUp() {

        saveButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(70+keyboardHeight)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        
        skipButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(30+keyboardHeight)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
            $0.centerX.equalToSuperview()
        }
        
        UIView.animate(withDuration: self.keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func moveButtonDown() {
        saveButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(90)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        
        skipButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(40)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
            $0.centerX.equalToSuperview()
        }
        
        UIView.animate(withDuration: self.keyboardDuration) {
            self.view.layoutIfNeeded()
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
