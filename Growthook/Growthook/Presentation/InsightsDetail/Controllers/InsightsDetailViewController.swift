//
//  InsightsDetailViewController.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

final class InsightsDetailViewController: BaseViewController {

    private let disposeBag = DisposeBag()
    private var viewModel: InsightsDetailViewModel
    private var mainBlockHeight: CGFloat
    private var mainBlockColor: UIColor
    private var hasActionPlan: Bool
    
    private let customNavigationView = CommonCustomNavigationBar()
    private let mainInsightBlock = InsightView()
    private let memoView = InsightsDetailMemoView()
    private lazy var actionPlanCollectionView = UICollectionView(frame: .zero, collectionViewLayout: setFlowLayout())
    private var actionPlanButton: BottomCTAButton
    
    init(hasAnyActionPlan: Bool, seedId: Int) {
        self.viewModel = InsightsDetailViewModel(hasAnyActionPlan: hasAnyActionPlan, seedId: seedId)
        self.hasActionPlan = hasAnyActionPlan
        
        if hasAnyActionPlan != false {
            mainBlockHeight = 125
            mainBlockColor = .gray600
            actionPlanButton = BottomCTAButton(type: .addAction)
        } else {
            mainBlockHeight = 108
            mainBlockColor = .gray700
            actionPlanButton = BottomCTAButton(type: .createAction)
        }
        super.init(nibName: nil, bundle: nil)
    }

    override func bindViewModel() {
        // MARK: - Bind UI With Data
        viewModel.outputs.seedDetail
            .bind { [weak self] data in
                guard let self else { return }
                let model: InsightModel = .init(name: data.caveName, insight: data.insight, date: data.lockDate, dDay: String(data.remainingDays), memo: data.memo)
                mainInsightBlock.bindInsight(model: model)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.actionPlans
            .bind(to: actionPlanCollectionView.rx.items(cellIdentifier: InsightsDetailActionPlanCollectionViewCell.className, cellType: InsightsDetailActionPlanCollectionViewCell.self)) { item, data, cell in
                cell.setContent(of: data.content)
                cell.setIsCompleted(data.isFinished)
                cell.rxMenuButtonTapControl
                    .bind { [weak self] _ in
                        guard let self else { return }
                        self.showMenuViewFromCell()
                    }
                    .disposed(by: cell.disposeBag)
                cell.rxCompleteButtonTapControl
                    .bind { [weak self] _ in
                        guard let self else { return }
                        self.showCompleteActionPlanView()
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
                    // 이 Controller 에서 토스트가 뜨지 않음
                    break
                default:
                    // 나머지는 따로 CallBack 으로 toast 띄움
                    break
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
                    self.showAlert(alertText: "네트워크가 약합니다.", alertMessage: "네트워크 환경을 다시 확인해주세요.")
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - Button Actions - Present/Navigation
        
        customNavigationView.rxDoneButtonTapControl
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.navigationBarMenuDidTap()
                self.presentMenuView()
            }
            .disposed(by: disposeBag)
        
        actionPlanButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.showAddEtraActionPlanView()
            }
            .disposed(by: disposeBag)
        
    }
    
    override func setRegister() {
        actionPlanCollectionView.register(InsightsDetailActionPlanCollectionViewCell.self, forCellWithReuseIdentifier: InsightsDetailActionPlanCollectionViewCell.className)
    }
    
    override func setStyles() {
        view.backgroundColor = .gray700
        
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
        }
    }
    
    override func setLayout() {
        view.addSubviews(
            customNavigationView,mainInsightBlock, memoView,
            actionPlanButton, actionPlanCollectionView
        )
        
        customNavigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 48 / 812)
        }
        
        mainInsightBlock.snp.makeConstraints {
            $0.height.equalTo(mainBlockHeight)
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(customNavigationView.snp.bottom)
        }
        
        memoView.snp.makeConstraints {
            $0.top.equalTo(mainInsightBlock.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.lessThanOrEqualTo(500)
        }
        
        actionPlanButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(54)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.height.equalTo(50)
        }
        
        actionPlanCollectionView.snp.makeConstraints {
            $0.top.equalTo(mainInsightBlock.snp.bottom).offset(20)
            $0.bottom.equalTo(actionPlanButton.snp.top).offset(-5)
            $0.horizontalEdges.equalToSuperview()
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
    
    private func showMenuViewFromCell() {
        
    }
    
    private func showEditActionPlanView() {
        
    }
    
    private func showCompleteActionPlanView() {
        
    }
    
    private func showDeleteActionPlanPopView() {
        
    }
    
    private func presentMenuView() {
        
    }
    
    private func showAddEtraActionPlanView() {
        
    }
    
    private func showEditActionPlanview() {
        
    }
}
