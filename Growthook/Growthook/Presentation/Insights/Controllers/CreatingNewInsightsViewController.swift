//
//  CreatingNewInsightsViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 11/12/23.
//

import UIKit

import RxCocoa
import RxSwift

protocol NewInsightMadeDelegate: AnyObject {
    func presentDetailView(seedIdOf: Int)
}

final class CreatingNewInsightsViewController: BaseViewController {

    // MARK: - Properties
    weak var delegate: NewInsightMadeDelegate?
    private let disposeBag = DisposeBag()
    private let viewModel = InsightsViewModel()
    private var previousFocusCoordinates: CGPoint = .zero
    private var currentScrollCoordinates: CGPoint = .zero
    
    // MARK: - UI Properties
    private let customNavigationView = CommonCustomNavigationBar()
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let creatingContentView = CreatingNewInsightsView()
    private let loadingView = FullCoverLoadingView()
    
    override func bindViewModel() {
        // MARK: - Bind UI to State
        viewModel.outputs.networkState
            .bind { [weak self] status in
                guard let self else { return }
                switch status {
                case .normal:
                    break
                case .networkLost:
                    self.showLoadingView(false)
                    self.showAlertWithError(alertText: "네트워크 환경이 좋지 않아요!", alertMessage: "네트워크 연결 상태를 확인하고 다시 시도해주세요.") { _ in
                        self.viewModel.inputs.cancelErrorAlert()
                    }
                case .loading:
                    self.showLoadingView(true)
                case .error(let error):
                    self.showLoadingView(false)
                    self.showAlertWithError(alertText: "에러가 발생했어요!", alertMessage: "작성하신 글을 검토하고 다시 시도해주세요.", error: error) { _ in
                        self.viewModel.inputs.cancelErrorAlert()
                    }
                case .done:
                    self.showLoadingView(false)
                    // 수정하기
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - Edit Status Actions - Scroll
        Observable.combineLatest(
            creatingContentView.insightTextView.textViewBlock
            .rxEditingAction,
            creatingContentView.insightTextView.textViewBlock.rx.text.distinctUntilChanged()
        )
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] event, text in
                guard let self, let text else { return }
                switch event {
                case .editingDidBegin:
                    let point = self.creatingContentView.insightTextView.frame.origin
                    scrollToNewPoint(currentPoint: point)
                case .editingDidEnd:
                    self.viewModel.inputs.addInsight(content: text)
                    scrollToTop()
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        creatingContentView.insightTextView.textViewBlock.rxNextButtonTapControl
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let self else { return }
                self.creatingContentView.memoTextView.textViewBlock.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            creatingContentView.memoTextView.textViewBlock
            .rxEditingAction,
            creatingContentView.memoTextView.textViewBlock.rx.text.distinctUntilChanged()
        )
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] event, text in
                guard let self, let text else { return }
                switch event {
                case .editingDidBegin:
                    let point = self.creatingContentView.memoTextView.frame.origin
                    scrollToNewPoint(currentPoint: point)
                case .editingDidEnd:
                    self.viewModel.inputs.addMemo(content: text)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        creatingContentView.memoTextView.textViewBlock
            .rxNextButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.creatingContentView.memoTextView.textViewBlock.resignFirstResponder()
                let component = self.creatingContentView.referenceTextField
                let point = component.frame.origin
                let height = component.frame.height
                scrollToNewPoint(currentPoint: point, height: height + 50)
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(
            creatingContentView.referenceTextField.textFieldBlock
            .rxEditingAction,
            creatingContentView.referenceTextField.textFieldBlock.rx.text.distinctUntilChanged()
        )
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] event, text in
                guard let self, let text else { return }
                let textField = self.creatingContentView.referenceTextField
                switch event {
                case .editingDidBegin:
                    textField.textFieldBlock.focusWhenDidBeginEditing()
                    let point = textField.frame.origin
                    let height = textField.frame.height
                    scrollToNewPoint(currentPoint: point, height: height)
                case .editingDidEnd:
                    textField.textFieldBlock.unfocusWhenDidEndEditing()
                    self.viewModel.inputs.addReference(content: text)
                    scrollToBottom()
                case .editingDidEndOnExit:
                    self.viewModel.inputs.addReference(content: text)
                    self.resignFirstResponder()
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            creatingContentView.referencURLTextField.textFieldBlock.rxEditingAction,
            creatingContentView.referencURLTextField.textFieldBlock.rx.text.distinctUntilChanged()
        )
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] event, text in
                guard let self, let text else { return }
                let textField = self.creatingContentView.referencURLTextField
                switch event {
                case .editingDidBegin:
                    textField.textFieldBlock.focusWhenDidBeginEditing()
                    let point = textField.frame.origin
                    let height = textField.frame.height
                    scrollToNewPoint(currentPoint: point, height: height)
                case .editingDidEnd:
                    textField.textFieldBlock.unfocusWhenDidEndEditing()
                    self.viewModel.inputs.addReferenceUrl(content: text)
                    scrollToBottom()
                case .editingDidEndOnExit:
                    self.resignFirstResponder()
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - Button Actions - Present/Navigation
        customNavigationView.rxBackButtonTapControl
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        creatingContentView.selectCaveView.rxButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.presentCaveViewController()
            }
            .disposed(by: disposeBag)
        
        creatingContentView.goalPeriodSelectView.rxButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.presentPeriodViewController()
            }
            .disposed(by: disposeBag)
        
        // MARK: - Button Actions - Post
        customNavigationView.rxDoneButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.postNewInsight { seedId in
                    if let seedId {
                        let vc = UINavigationController(rootViewController: InsightsDetailModalViewController(hasAnyActionPlan: false, seedId: seedId))
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    } else {
                        self.showAlertWithError(alertText: "다시 시도해주세요.", alertMessage: "에러가 발생했어요.")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - Bind UI With Data
        viewModel.outputs.isPostingValid
            .bind { [weak self] isValid in
                guard let self else { return }
                self.customNavigationView.isButtonEnabled(isValid)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectedCave
            .bind { [weak self] cave in
                guard let self else { return }
                guard let cave else { return }
                self.creatingContentView.selectCaveView.setSelectedBlockText(with: cave.caveTitle)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectedPeriod
            .bind { [weak self] period in
                guard let self else { return }
                guard let period else { return }
                self.creatingContentView.goalPeriodSelectView.setSelectedBlockText(with: period.periodTitle)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Styles
    override func setStyles() {
        view.backgroundColor = .gray700
        
        customNavigationView.do {
            $0.setTitle(with: "새로운 씨앗 심기")
        }
        
        scrollView.do {
            $0.isScrollEnabled = true
            $0.showsVerticalScrollIndicator = false
            $0.delegate = self
        }
        
        loadingView.do {
            $0.isHidden = true
        }
    }
    
    // MARK: - Layout
    override func setLayout() {
        view.addSubviews(customNavigationView, scrollView, loadingView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(creatingContentView)
        
        customNavigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 48 / 812)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        creatingContentView.snp.makeConstraints {
            $0.horizontalEdges.verticalEdges.equalToSuperview()
            $0.height.equalTo(NewInsightItems.totalHeight)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
    // MARK: - Presenting Helpers
extension CreatingNewInsightsViewController {
    
    private func presentCaveViewController() {
        let caveBottomSheetViewController = InsightSelectCaveSheetViewController(viewModel: self.viewModel)
        caveBottomSheetViewController.modalPresentationStyle = .pageSheet
        if let sheet = caveBottomSheetViewController.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in return 380 })
            ]
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = true
        }
        present(caveBottomSheetViewController, animated: true)
    }
    
    private func presentPeriodViewController() {
        let goalPeriodBottomSheetViewController = InsightSelectPeriodSheetViewController(viewModel: self.viewModel)
        viewModel.inputs.setPeriodDataWhenSheetIsPresented()
        
        goalPeriodBottomSheetViewController.modalPresentationStyle = .pageSheet
        if let sheet = goalPeriodBottomSheetViewController.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in return 320 })
            ]
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = true
        }
        present(goalPeriodBottomSheetViewController, animated: true)
    }
}

    // MARK: - Scrolling Helpers
extension CreatingNewInsightsViewController: UIScrollViewDelegate {
 
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        currentScrollCoordinates = targetContentOffset.pointee
    }
    
    private func scrollToNewPoint(currentPoint: CGPoint, height: CGFloat = 0) {
        // 기존의 위치를 저장합니다.
        previousFocusCoordinates = currentPoint
        // 키보드의 위치 값을 고려해 보정하고 이동합니다.
        if currentPoint.y < 300 {
            if currentScrollCoordinates.y > 0 {
                  scrollToTop()
            } else {
                return
            }
        } else {
            let modifiedPoint = CGPoint(x: 0, y: currentPoint.y + height - 400)
            scrollView.setContentOffset(modifiedPoint, animated: true)
            currentScrollCoordinates = modifiedPoint
        }
    }
    
    private func scrollToTop() {
        scrollView.setContentOffset(.zero, animated: true)
        currentScrollCoordinates = .zero
    }
    
    private func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom + 25)
        if bottomOffset.y > 0 {
            scrollView.setContentOffset(bottomOffset, animated: true)
            currentScrollCoordinates = bottomOffset
        }
    }
}

    // MARK: - Alert Helper
    // TODO: 이건 무조건 한번에 컴포넌트로 처리해야함
extension CreatingNewInsightsViewController {
    
    func showAlertWithError(alertText: String, alertMessage: String, error: Error? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(
            title: alertText,
            message: alertMessage,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: handler))
        self.present(alert, animated: true)
    }
    
    func showLoadingView(_ isHidden: Bool) {
        loadingView.isHidden = !isHidden
    }
}
