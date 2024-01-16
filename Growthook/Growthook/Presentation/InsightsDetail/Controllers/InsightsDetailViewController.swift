//
//  InsightsDetailViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

protocol InsightBoxViewType: AnyObject {
    func bindInsight(model: InsightModel)
    func showDetail()
    func fold() 
    var moreButton: UIButton { get }
}

final class InsightsDetailViewController: BaseViewController {

    private let disposeBag = DisposeBag()
    private var viewModel: InsightsDetailViewModel
    private var mainBlockHeight: CGFloat
    private var mainBlockColor: UIColor
    private var hasActionPlan: Bool
    private var isFolded = true
    private let refreshControl = UIRefreshControl()
    private lazy var cellMenuView = ActionPlanCellMenuView()
    private var selectedActionPlanId = 0
    
    private let uselessBoxView = UIView()
    private let customNavigationView = CommonCustomNavigationBar()
    private var mainInsightBlock: InsightBoxViewType
    private let memoView = InsightsDetailMemoView()
    private let deleteAlertView = RemoveAlertView()
    private let deleteActionPlanView = RemoveAlertView()
    private lazy var actionPlanCollectionView = UICollectionView(frame: .zero, collectionViewLayout: setFlowLayout())
    private var actionPlanButton: BottomCTAButton
    private let loadingView = FullCoverLoadingView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFolded = true
        navigationController?.navigationBar.isHidden = true
    }
    
    init(hasAnyActionPlan: Bool, seedId: Int) {
        self.viewModel = InsightsDetailViewModel(hasAnyActionPlan: hasAnyActionPlan, seedId: seedId)
        self.hasActionPlan = hasAnyActionPlan
        
        if hasAnyActionPlan != false {
            mainBlockHeight = 125
            mainBlockColor = .gray600
            actionPlanButton = BottomCTAButton(type: .addAction)
            mainInsightBlock = InsightView()
        } else {
            mainBlockHeight = 113
            mainBlockColor = .gray700
            actionPlanButton = BottomCTAButton(type: .createAction)
            mainInsightBlock = InsightsDetailMainBlockView()
        }
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Bind
    override func bindViewModel() {
        // MARK: - Bind UI With Data
        viewModel.outputs.seedDetail
            .bind { [weak self] data in
                guard let self else { return }
                let model: InsightModel = .init(name: data.caveName, insight: data.insight, date: data.lockDate, dDay: String(data.remainingDays), memo: data.memo)
                mainInsightBlock.bindInsight(model: model)
                memoView.setMemoContent(with: model.memo)
                memoView.setReferenceContent(reference: data.source, url: data.url)
            }
            .disposed(by: disposeBag)
        
        
        viewModel.outputs.actionPlans
            .bind(to: actionPlanCollectionView.rx.items(cellIdentifier: InsightsDetailActionPlanCollectionViewCell.className, cellType: InsightsDetailActionPlanCollectionViewCell.self)) { [weak self] item, data, cell in
                guard let self else { return }
                cell.setContent(of: data.content)
                cell.setIsCompleted(data.isFinished)
                cell.rxMenuButtonTapControl
                    .bind { _ in
                        guard let point = cell.menuButton.superview?.convert(cell.menuButton.frame, to: self.view) else { return }
                        self.showMenuViewFromCell(actionId: data.actionPlanId, at: point, content: data.content)
                    }
                    .disposed(by: cell.disposeBag)
                cell.rxCompleteButtonTapControl
                    .bind { _ in
                        self.showCompleteActionPlanView(actionPlanId: data.actionPlanId)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.shouldHideMemoView
            .bind { [weak self] shouldHide in
                guard let self else { return }
                self.memoView.isHidden = shouldHide
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.toastStatus
            .bind { [weak self] status in
                guard let self else { return }
                print("status:", status)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                    switch status {
                    case .none:
                        break
                    case .scrapToast(let success):
                        self.view.showScrapToast(message: status.toastMessage, success: success)
                    case .moveSeedToast(let success):
                        self.view.showToast(message: status.toastMessage, success: success)
                    case .editSeedToast(let success):
                        self.view.showToast(message: status.toastMessage, success: success)
                    case .deleteSeedToast:
                        self.view.showToast(message: status.toastMessage, success: false)
                    case .createActionPlan(let success):
                        self.view.showToast(message: status.toastMessage, success: success)
                    case .editActionPlan(let success):
                        self.view.showToast(message: status.toastMessage, success: success)
                    case .deleteActionPlan(let success):
                        self.view.showToast(message: status.toastMessage, success: success)
                    default:
                        // 나머지는 따로 CallBack 으로 toast 띄움
                        break
                    }
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.networkStatus
            .bind { [weak self] status in
                guard let self else { return }
                switch status {
                case .normal:
                    break
                case .error(let error):
                    print(error)
                    self.showAlert(alertText: "네트워크가 약합니다.", alertMessage: "네트워크 환경을 다시 확인해주세요.")
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - Button Actions - Present/Navigation
        mainInsightBlock.moreButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                if isFolded != false {
                    self.setDownAnimation()
                } else {
                    self.setUpAnimation()
                }
            }
            .disposed(by: disposeBag)
        
        customNavigationView.rxDoneButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.navigationBarMenuDidTap()
                self.presentMenuView()
            }
            .disposed(by: disposeBag)
        
        customNavigationView.rxBackButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        actionPlanCollectionView.rx.didScroll
            .bind { [weak self] in
                guard let self else { return }
                self.cellMenuView.isHidden = true
                if self.actionPlanCollectionView.contentOffset.y < -130 {
                    if !self.refreshControl.isRefreshing {
                        self.loadingView.isHidden = false
                        self.reloadView()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        actionPlanButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.showAddEtraActionPlanView()
            }
            .disposed(by: disposeBag)
        
        deleteAlertView.keepButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.dismissDeleteAlertView()
            }
            .disposed(by: disposeBag)
        
        deleteAlertView.removeButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                // MARK: 이거도 아마 안될걸 ? 바꿔
                self.viewModel.deleteSeedDidTap { success in
                    if success != false {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
                
        deleteActionPlanView.keepButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.dismissDeleteActionPlanView()
            }
            .disposed(by: disposeBag)
        
        deleteActionPlanView.removeButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.deleteActionPlan(actionPlanId: self.selectedActionPlanId) { success in
                    switch success {
                    case true:
                        self.deleteActionPlanView.isHidden = true
                    case false:
                        break
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Register
    override func setRegister() {
        actionPlanCollectionView.register(InsightsDetailActionPlanCollectionViewCell.self, forCellWithReuseIdentifier: InsightsDetailActionPlanCollectionViewCell.className)
    }
    
    // MARK: - Style
    override func setStyles() {
        view.backgroundColor = .gray700
        
        uselessBoxView.backgroundColor = mainBlockColor
        
        customNavigationView.do {
            $0.modifyActionButtonConfigurationWithSymbol(of: "ellipsis")
            $0.isButtonEnabled(true)
            $0.setTitle(with: "씨앗 정보")
            $0.setBackgroundColor(mainBlockColor)
            $0.setButtonColorForWhen(enabled: .white000, disabled: .white000)
        }
        
        memoView.do {
            $0.isHidden = hasActionPlan
        }
        
        actionPlanCollectionView.do {
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .clear
            $0.isScrollEnabled = true
        }
        
        refreshControl.do {
            $0.tintColor = .green400
        }
        
        deleteAlertView.descriptionLabel.text = I18N.Component.RemoveAlert.removeInsight
        deleteAlertView.isHidden = true
        deleteActionPlanView.descriptionLabel.text = I18N.Component.RemoveAlert.removeActionPlan
        deleteActionPlanView.isHidden = true
        cellMenuView.isHidden = true
        loadingView.isHidden = true
    }
    
    // MARK: - Layout
    override func setLayout() {
        let mainBlock = mainInsightBlock as! UIView
        let removeMenuTap = UITapGestureRecognizer(target: self, action: #selector(hidemenu))
        view.addGestureRecognizer(removeMenuTap)
        
        view.addSubviews(
            uselessBoxView, customNavigationView, mainBlock,
            memoView, actionPlanButton, actionPlanCollectionView,
            deleteAlertView, deleteActionPlanView, loadingView
        )
        
        uselessBoxView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        customNavigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 48 / 812)
        }
        
        mainBlock.snp.makeConstraints {
            $0.height.equalTo(mainBlockHeight)
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(customNavigationView.snp.bottom)
        }
        
        memoView.snp.makeConstraints {
            $0.top.equalTo(mainBlock.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.lessThanOrEqualTo(500)
        }
        
        actionPlanButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(54)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        
        actionPlanCollectionView.snp.makeConstraints {
            $0.top.equalTo(mainBlock.snp.bottom).offset(20)
            $0.bottom.equalTo(actionPlanButton.snp.top).offset(-5)
            $0.horizontalEdges.equalToSuperview()
        }
        
        deleteAlertView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(173)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        deleteActionPlanView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(173)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints {
            $0.top.equalTo(mainBlock.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(actionPlanCollectionView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsightsDetailViewController {
    
    private func setFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 12
        flowLayout.itemSize = CGSize(width: view.frame.size.width - 36, height: 100)
        return flowLayout
    }
    
    // MARK: - showMenuViewFromCell
    private func showMenuViewFromCell(actionId: Int, at location: CGRect, content: String) {
        cellMenuView.isHidden = true
        cellMenuView = ActionPlanCellMenuView()
        cellMenuView.setActionId(actionId)
        self.selectedActionPlanId = actionId
        view.addSubview(cellMenuView)
        
        cellMenuView.isHidden = false
        cellMenuView.snp.remakeConstraints {
            $0.width.equalTo(61)
            $0.height.equalTo(84)
            $0.top.equalToSuperview().inset(location.origin.y + 40)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        cellMenuView.rxEditButtonControl
            .bind { [weak self] in
                guard let self else { return }
                self.showEditActionPlanview(actionId: cellMenuView.actionPlanId, content: content)
                self.cellMenuView.isHidden = true
            }
            .disposed(by: disposeBag)
        
        cellMenuView.rxDeleteButtonControl
            .bind { [weak self] in
                guard let self else { return }
                self.cellMenuView.isHidden = true
                self.showDeleteActionPlanPopView()
            }
            .disposed(by: disposeBag)
    }
    
    private func showCompleteActionPlanView(actionPlanId: Int) {
        let completeViewController = InsigthDetailActionPlanReviewSheetViewController(viewModel: self.viewModel, actionPlanId: actionPlanId)
        completeViewController.delegate = self
        completeViewController.modalPresentationStyle = .pageSheet
        if let sheet = completeViewController.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in return 560 })
            ]
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = false
        }
        present(completeViewController, animated: true)
    }
    
    private func showDeleteActionPlanPopView() {
        deleteActionPlanView.isHidden = false
    }
    
    private func presentMenuView() {
        let seedMenuViewController = InsightDetailMenuViewController(viewModel: self.viewModel)
        seedMenuViewController.modalPresentationStyle = .pageSheet
        seedMenuViewController.delegate = self
        if let sheet = seedMenuViewController.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in return 240 })
            ]
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = true
        }
        present(seedMenuViewController, animated: true)
    }
    
    private func showAddEtraActionPlanView() {
        let createSingleActionPlanViewController = InsigthDetailActionPlanSheetViewController(purpose: .create, viewModel: self.viewModel)
        createSingleActionPlanViewController.modalPresentationStyle = .pageSheet
        if let sheet = createSingleActionPlanViewController.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in return 380 })
            ]
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = false
        }
        present(createSingleActionPlanViewController, animated: true)
    }
    
    private func showEditActionPlanview(actionId: Int, content: String) {
        let editActionPlanViewController = InsigthDetailActionPlanSheetViewController(purpose: .edit(actionPlanId: actionId), viewModel: self.viewModel, originalContentText: content)
        editActionPlanViewController.modalPresentationStyle = .pageSheet
        if let sheet = editActionPlanViewController.sheetPresentationController {
            sheet.detents = [
                .custom(resolver: { context in return 380 })
            ]
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = false
        }
        present(editActionPlanViewController, animated: true)
    }
    
    private func setUpAnimation() {
        let mainBlock = mainInsightBlock as! InsightView

        UIView.animate(withDuration: 0.4, animations: { [self] in
            mainBlock.frame.size.height = 125
            mainInsightBlock.fold()
        })
        setFoldingLayout()
    }
    
    private func setDownAnimation() {
        let mainBlock = mainInsightBlock as! InsightView

        UIView.animate(withDuration: 0.4, animations: { [self] in
            mainBlock.frame.size.height = 153 + 125
            mainInsightBlock.showDetail()
        })
        setShowingLayout()
    }
    
    private func showDeleteAlertView() {
        deleteAlertView.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func dismissDeleteAlertView() {
        deleteAlertView.isHidden = true
    }
    
    private func dismissDeleteActionPlanView() {
        deleteActionPlanView.isHidden = true
    }
    
    private func setFoldingLayout() {
        let mainBlock = mainInsightBlock as! InsightView

        mainBlock.snp.remakeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(125)
        }
        isFolded = true
    }
    
    private func setShowingLayout() {
        let mainBlock = mainInsightBlock as! InsightView

        mainBlock.snp.remakeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(278)
        }
        isFolded = false
    }
    
    private func reloadView() {
        print("REFRESH 🔥")
        viewModel.inputs.reloadSeedData()
        viewModel.inputs.reloadActionPlan()
        refreshControl.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
            self.loadingView.isHidden = true
        }
    }
    
    @objc
    private func hidemenu() {
        cellMenuView.isHidden = true
    }
}

extension InsightsDetailViewController: InsightMenuDelegate, CompleteReviewDelegate {
    
    func pushToEditView() {
        let existingData = viewModel.inputs.fetchSeedModel()
        let editingSeedViewController = InsightDetailEditSeedViewController(presentingViewModel: self.viewModel, seedEditModel: existingData)
        navigationController?.pushViewController(editingSeedViewController, animated: true)
    }
    
    func dismissAndShowAlertView() {
        showDeleteAlertView()
    }
    
    func dismissWithAlertView() {
        let finishedAlertView = AlertViewController()
        finishedAlertView.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
            self.present(finishedAlertView, animated: false)
        }
    }
}
