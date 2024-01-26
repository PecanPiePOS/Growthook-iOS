//
//  InsightsDetailModalViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/26/24.
//

import UIKit

import RxCocoa
import RxSwift


final class InsightsDetailModalViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private var viewModel: InsightsDetailViewModel
    private var mainBlockHeight: CGFloat
    private var mainBlockColor: UIColor
    private var hasActionPlan: Bool {
        didSet {
            switch self.hasActionPlan {
            case true:
                self.actionPlanButton.setTitleIfNeeded(with: "액션 더하기")
            case false:
                self.actionPlanButton.setTitleIfNeeded(with: "액션 만들기")

            }
        }
    }
    private var isFolded = true
    private let refreshControl = UIRefreshControl()
    private lazy var cellMenuView = ActionPlanCellMenuView()
    private var selectedActionPlanId = 0
    
    private let uselessBoxView = UIView()
    private let customNavigationView = CommonCustomNavigationBar()
    
    private var mainBlockWithMemoView = InsightsDetailMainBlockView()
    private var mainBlockWithActionPlanView = InsightView()
    
    private let memoView = InsightsDetailMemoView()
    private let deleteAlertView = RemoveAlertView2()
    private let deleteActionPlanView = RemoveAlertView2()
    private lazy var actionPlanCollectionView = UICollectionView(frame: .zero, collectionViewLayout: setFlowLayout())
    private var actionPlanButton: BottomCTAButton = .init(type: .createAction)
    private let decoyScrapButton = UIButton()
    
    private let alertBackground = UIView()
    private let alertImageView = UIImageView()
    private let dismissButton = UIButton()
    
    private let loadingView = FullCoverLoadingView()
    private var seedId = 0
    private var isFirstOpened = true
    private var isScraped = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFolded = true
        navigationController?.navigationBar.isHidden = true
//
//        if isFirstOpened != false {
//            isFirstOpened = false
//        } else {
//            // Reload 하는 뷰 만들기.
//        }
    }
    
    init(hasAnyActionPlan: Bool, seedId: Int) {
        self.viewModel = InsightsDetailViewModel(hasAnyActionPlan: hasAnyActionPlan, seedId: seedId)
        self.hasActionPlan = hasAnyActionPlan
        self.seedId = seedId
        
        if hasAnyActionPlan != false {
            mainBlockHeight = HasAnyActionPlan.yes.height
            mainBlockColor = HasAnyActionPlan.yes.color
            actionPlanButton = BottomCTAButton(type: .addAction)
            mainBlockWithMemoView.isHidden = true
            mainBlockWithActionPlanView.isHidden = false
        } else {
            mainBlockHeight = HasAnyActionPlan.no.height
            mainBlockColor = HasAnyActionPlan.no.color
            actionPlanButton = BottomCTAButton(type: .createAction)
            mainBlockWithMemoView.isHidden = false
            mainBlockWithActionPlanView.isHidden = true
            decoyScrapButton.isHidden = true
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Bind
    override func bindViewModel() {
        
        // MARK: - Bind UI With Data
        viewModel.outputs.seedDetail
            .bind { [weak self] data in
                guard let self else { return }
                let model: ActionPlanResponse =
                    .init(caveName: data.caveName, insight: data.insight, memo: data.memo, source: data.source, url: data.url, isScraped: data.isScraped, lockDate: data.lockDate, remainingDays: data.remainingDays)
                mainBlockWithActionPlanView.bindInsight(model: model)
                mainBlockWithMemoView.bindInsight(model: model)
                memoView.setMemoContent(with: model.memo)
                memoView.setReferenceContent(reference: data.source, url: data.url)
                self.isScraped = data.isScraped
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.actionPlans
            .bind(to: actionPlanCollectionView.rx.items(cellIdentifier: InsightsDetailActionPlanCollectionViewCell.className, cellType: InsightsDetailActionPlanCollectionViewCell.self)) { [weak self] item, data, cell in
                guard let self else { return }
                cell.setContent(of: data.content)
                cell.setIsCompleted(data.isFinished)
                cell.setScrap(isScraped: data.isScraped)
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
                cell.scrapButton.rx.tap
                    .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
                    .bind { _ in
                        self.viewModel.inputs.actionPlanScrap(actionPlanId: data.actionPlanId) { success in
                            if success {
                                cell.toggleScrap()
                            }
                        }
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.shouldHideMemoView
            .bind { [weak self] shouldHide in
                guard let self else { return }
                self.memoView.isHidden = shouldHide
                
                if shouldHide != false {
                    self.actionPlanButton = BottomCTAButton(type: .addAction)
                    self.uselessBoxView.backgroundColor = HasAnyActionPlan.yes.color
                    self.actionPlanButton.setTitleIfNeeded(with: "액션 더하기")
                    self.mainBlockWithMemoView.isHidden = true
                    self.mainBlockWithActionPlanView.isHidden = false
                    self.customNavigationView.setBackgroundColor(HasAnyActionPlan.yes.color)
                    self.hasActionPlan = true
                    self.decoyScrapButton.isHidden = false
                } else {
                    self.actionPlanButton = BottomCTAButton(type: .createAction)
                    self.customNavigationView.showDoneButton()
                    self.uselessBoxView.backgroundColor = HasAnyActionPlan.no.color
                    self.actionPlanButton.setTitleIfNeeded(with: "액션 만들기")
                    self.mainBlockWithMemoView.isHidden = false
                    self.mainBlockWithActionPlanView.isHidden = true
                    self.customNavigationView.setBackgroundColor(HasAnyActionPlan.no.color)
                    self.hasActionPlan = false
                    self.decoyScrapButton.isHidden = true
                }
                
                self.customNavigationView.showDoneButton()
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
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.view.showToast(message: status.toastMessage, success: success)
                        }
                    case .editActionPlan(let success):
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                            self.view.showToast(message: status.toastMessage, success: success)
                        }
                    case .deleteActionPlan(let success):
                        self.view.showToast(message: status.toastMessage, success: success)
                    default:
                        // 나머지는 따로 CallBack 으로 toast 띄움
                        break
                    }
                    self.customNavigationView.showDoneButton()
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
        
        viewModel.outputs.scrapedStatus
            .bind { [weak self] isScraped in
                guard let self else { return }
                switch isScraped {
                case true:
                    self.isScraped = true
                    self.mainBlockWithMemoView.scrapButton
                        .setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
                    self.decoyScrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
                case false:
                    self.isScraped = false
                    self.mainBlockWithMemoView.scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
                    self.decoyScrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - Button Actions - Present/Navigation
        mainBlockWithActionPlanView.moreButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                if isFolded != false {
                    self.setDownAnimation()
                } else {
                    self.setUpAnimation()
                }
            }
            .disposed(by: disposeBag)
        
        mainBlockWithMemoView.scrapButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.insightScrap { success in
                    if success && self.isScraped == true {
                        self.decoyScrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
                        self.isScraped = false
                    } else if success && self.isScraped == false {
                        self.decoyScrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
                        self.isScraped = true
                    }
                }
            }
            .disposed(by: disposeBag)
        
        customNavigationView.rxDoneButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
                self.goBackToRootView()
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
        
        actionPlanButton.rx.tap.throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let self else { return }
                switch self.hasActionPlan {
                case true:
                    self.showAddEtraActionPlanView()
                case false:
                    self.showAddNewActionPlanView()
                }
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
                self.viewModel.deleteSeedDidTap { success in
                    if success != false {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        decoyScrapButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.insightScrap { success in
                    if success && self.isScraped == true {
                        self.decoyScrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
                        self.isScraped = false
                    } else if success && self.isScraped == false {
                        self.decoyScrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
                        self.isScraped = true
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
                        self.deleteActionPlanView.isHidden = true
                    }
                }
            }
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.alertBackground.removeFromSuperview()
                self.alertImageView.removeFromSuperview()
                self.dismissButton.isHidden = true
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
            $0.modifyActionButtonConfigurationWithSymbol(of: "xmark")
            $0.isButtonEnabled(true)
            $0.setTitle(with: "씨앗 정보")
            $0.setBackgroundColor(mainBlockColor)
            $0.setButtonColorForWhen(enabled: .white000, disabled: .white000)
            $0.hideBackButton()
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
        
        alertBackground.do {
            $0.backgroundColor = .black000.withAlphaComponent(0.6)
        }
        
        alertImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "newSeedAlert")
        }
    }
    
    // MARK: - Layout
    override func setLayout() {
        let removeMenuTap = UITapGestureRecognizer(target: self, action: #selector(hidemenu))
        view.addGestureRecognizer(removeMenuTap)
        
        view.addSubviews(
            uselessBoxView, customNavigationView, mainBlockWithMemoView, mainBlockWithActionPlanView,
            memoView, actionPlanButton, actionPlanCollectionView,
            deleteAlertView, deleteActionPlanView, loadingView,
            decoyScrapButton, alertBackground, alertImageView,
            dismissButton
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
        
        mainBlockWithMemoView.snp.makeConstraints {
            $0.height.equalTo(HasAnyActionPlan.no.height)
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(customNavigationView.snp.bottom)
        }
        
        mainBlockWithActionPlanView.snp.makeConstraints {
            $0.height.equalTo(HasAnyActionPlan.yes.height)
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(customNavigationView.snp.bottom)
        }
        
        memoView.snp.makeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom).offset(HasAnyActionPlan.no.height)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.lessThanOrEqualTo(500)
        }
        
        actionPlanButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(54)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        
        actionPlanCollectionView.snp.makeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom).offset(HasAnyActionPlan.yes.height + 28)
            $0.bottom.equalTo(actionPlanButton.snp.top).offset(-5)
            $0.horizontalEdges.equalToSuperview()
        }
        
        deleteAlertView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        deleteActionPlanView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints {
            $0.top.equalTo(actionPlanCollectionView)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(actionPlanCollectionView)
        }
        
        decoyScrapButton.snp.makeConstraints {
            $0.top.equalTo(mainBlockWithActionPlanView.snp.top).inset(10)
            $0.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(48)
        }
        
        alertBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        alertImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(3.34)
            $0.width.equalToSuperview().dividedBy(1.29)
        }
        
        dismissButton.snp.makeConstraints {
            $0.width.equalTo(alertImageView)
            $0.height.equalTo(50)
            $0.bottom.equalTo(alertImageView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InsightsDetailModalViewController {
    
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
    
    private func showAddNewActionPlanView() {
        let vc = CreateActionViewControlller()
        vc.delegate = self
        vc.seedId = self.seedId
        self.navigationController?.pushViewController(vc, animated: true)
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
        UIView.animate(withDuration: 0.4, animations: { [self] in
            mainBlockWithActionPlanView.frame.size.height = 125
            mainBlockWithActionPlanView.fold()
        })
        setFoldingLayout()
    }
    
    private func setDownAnimation() {
        UIView.animate(withDuration: 0.4, animations: { [self] in
            mainBlockWithActionPlanView.frame.size.height = 153 + 125
            mainBlockWithActionPlanView.showDetail()
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
        mainBlockWithActionPlanView.snp.remakeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(135)
        }
        
        actionPlanCollectionView.snp.updateConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom).offset(HasAnyActionPlan.yes.height + 28)
        }
        
        isFolded = true
    }
    
    private func setShowingLayout() {
        mainBlockWithActionPlanView.snp.remakeConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(278)
        }
        
        actionPlanCollectionView.snp.updateConstraints {
            $0.top.equalTo(customNavigationView.snp.bottom).offset(HasAnyActionPlan.yes.height + 28 + 143)
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
    
    private func goBackToRootView() {
        let mainViewController = TabBarController()
        mainViewController.selectedIndex = 0
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        sceneDelegate.window?.makeKeyAndVisible()
    }
}

extension InsightsDetailModalViewController: InsightMenuDelegate, CompleteReviewDelegate {
    
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

extension InsightsDetailModalViewController: InsightDetailReloadDelegate {
    func reloadAfterPost() {
        DispatchQueue.main.asyncAfter(deadline: .now()+1.2) {
            self.viewModel.inputs.reloadActionPlan()
            self.actionPlanButton = .init(type: .addAction)
            self.viewModel.toastStatus.accept(.createActionPlan(success: true))
            self.hasActionPlan = true
        }
    }
}
