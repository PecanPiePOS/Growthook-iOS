//
//  HomeViewController.swift
//  Growthook
//
//  Created by KJ on 11/5/23.
//

import UIKit

import Alamofire
import Moya
import SnapKit
import Then
import RxCocoa
import RxSwift

enum ClearInsightType {
    case move
    case delete
    case none
    case deleteCave
}

final class HomeViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let homeCaveView = HomeCaveView()
    private let insightListView = InsightListView()
    private let seedPlusButton = UIButton()
    private let unLockAlertView = UnLockInsightAlertView()
    private let notificationView = NotificationAlertView()
    private lazy var insightEmptyView = EmptySeedView()
    private lazy var insightListEmptyView = InsightListEmptyView()
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
    private var lockSeedId: Int?
    private var lockActionPlan: Bool?
    private var isFirstLaunched: Bool = true
    private var isCaveEmpty: Bool = true
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        let memberId = viewModel.memberId
        if !isFirstLaunched {
            viewModel.getCaveList(memberId: memberId)
            viewModel.getSeedList(memberId: memberId)
            viewModel.getSsukCount(memberId: memberId)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        setNotification()
        isFirstLaunched = false
    }
    
    override func bindViewModel() {
        
        viewModel.outputs.caveProfile
            .do(onNext: { [weak self] cave in
                guard cave.isEmpty else { return }
                self?.homeCaveView.caveEmptyView.isHidden = false
                self?.homeCaveView.caveCollectionView.isHidden = true
                self?.isCaveEmpty = true
            })
            .bind(to: homeCaveView.caveCollectionView.rx
                .items(cellIdentifier: CaveCollectionViewCell.className,
                       cellType: CaveCollectionViewCell.self)) { (index, model, cell) in
                self.homeCaveView.caveEmptyView.isHidden = true
                self.homeCaveView.caveCollectionView.isHidden = false
                self.isCaveEmpty = false
                cell.configureCell(model)
            }
                       .disposed(by: disposeBag)
        
        viewModel.outputs.insightList
            .do(onNext: { [weak self] list in
                guard list.isEmpty else { return }
                self?.insightEmptyView.isHidden = false
                self?.insightListView.isHidden = true
                self?.insightListEmptyView.isHidden = true
            })
            .map { [weak self] list in
                guard let type = self?.insightListView.scrapType else { return list }
                let scrapType = type ? list.filter { $0.isScraped } : list
                if scrapType.count == 0 {
                    self?.insightListEmptyView.isHidden = false
                } else {
                    self?.insightListEmptyView.isHidden = true
                }
                return scrapType
            }
        
            .bind(to: insightListView.insightCollectionView.rx
                .items(cellIdentifier: InsightListCollectionViewCell.className,
                       cellType: InsightListCollectionViewCell.self)) { (index, model, cell) in
                self.insightEmptyView.isHidden = true
                self.insightListView.isHidden = false
                self.insightListEmptyView.isHidden = true
                cell.configureCell(model)
                cell.setCellStyle()
                cell.scrapButtonTapHandler = { [weak self] in
                    guard let self = self else { return }
                    if !cell.isScrapButtonTapped {
                        self.view.showScrapToast(message: I18N.Component.ToastMessage.scrap)
                    } else {
                        self.view.showScrapToast(message: I18N.Component.ToastMessage.unScrap)
                    }
                    cell.isScrapButtonTapped.toggle()
                    self.viewModel.inputs.insightScrap(seedId: model.seedId)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.insightAllCount
            .subscribe(onNext: { [weak self] count in
                self?.insightListView.seedTitleLabel.text = "\(count)\(I18N.Home.seedsCollected)"
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.ssukCount
            .subscribe(onNext: { [weak self] model in
                self?.homeCaveView.seedCountLabel.text = (model.gatheredSsuk == 0) ? "00" : "\(model.gatheredSsuk)"
                self?.unLockAlertView.mugwortCount.text = (model.gatheredSsuk == 0) ? "00" : "\(model.gatheredSsuk)"
            })
            .disposed(by: disposeBag)
        
        // 인사이트 셀 스타일 재설정
        insightListView.insightCollectionView.rx.willDisplayCell
            .subscribe(onNext: { event in
                if let cell = event.cell as? InsightListCollectionViewCell {
                    cell.setCellStyle()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.insightLongTap
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.makeVibrate()
                self.presentToHalfModalViewController(indexPath)
                if let cell = insightListView.insightCollectionView.cellForItem(at: indexPath) as? InsightListCollectionViewCell {
                    cell.selectedCell()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.insightBackground
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if let cell = insightListView.insightCollectionView.cellForItem(at: indexPath) as? InsightListCollectionViewCell {
                    cell.unSelectedCell()
                }
            })
            .disposed(by: disposeBag)
        
        homeCaveView.caveCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if let cell = homeCaveView.caveCollectionView.cellForItem(at: indexPath) as? CaveCollectionViewCell {
                    guard let caveId = cell.caveId else { return }
                    self.viewModel.inputs.caveDetail(caveId: caveId)
                    self.viewModel.inputs.caveInsightList(caveId: caveId)
                    self.pushToCaveDetailVC(caveId: caveId)
                }
            })
            .disposed(by: disposeBag)
        
        insightListView.insightCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.inputs.insightCellTap(at: indexPath)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.pushToInsightDetail
            .subscribe(onNext: { [weak self] indexPath in
                self?.pushToInsightDetail(at: indexPath)
            })
            .disposed(by: disposeBag)
        
        unLockAlertView.giveUpButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.unLockAlertView.removeFromSuperview()
            })
            .disposed(by: disposeBag)
        
        unLockAlertView.useButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let seedId = self?.lockSeedId else { return }
                if self?.viewModel.ssukCount.value.gatheredSsuk == 0 {
                    self?.unLockAlertView.removeFromSuperview()
                    self?.view.showToastWithRed(message: I18N.Component.ToastMessage.unLockFail)
                } else {
                    self?.viewModel.inputs.unLockSeedAlert(seedId: seedId)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.unLockSeed
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.unLockAlertView.removeFromSuperview()
                guard let actionPlan = self.lockActionPlan else { return }
                guard let seedId = self.lockSeedId else { return }
                let vc = InsightsDetailViewController(hasAnyActionPlan: actionPlan, seedId: seedId)
                vc.hidesBottomBarWhenPushed = true
                vc.view.showToast(message: I18N.Component.ToastMessage.unLockSuccess)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        homeCaveView.addCaveButton.rx.tap
            .subscribe(onNext: { _ in
                let vc = CreateCaveViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        seedPlusButton.rx.tap
            .subscribe(onNext: { _ in
                if self.isCaveEmpty {
                    self.presentToEmptyCaveListVC()
                } else {
                    let vc = CreatingNewInsightsViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        homeCaveView.notificationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let memberId = self?.viewModel.memberId else { return }
                self?.viewModel.inputs.alarmButtonTap(memberId: memberId)
                self?.notificationButtonTap()
            })
            .disposed(by: disposeBag)
        
        insightListView.scrapButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if let type = self?.insightListView.scrapType {
                    self?.viewModel.inputs.onlyScrapInsight()
                    self?.scrapTypeSetting(type)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.insightAlarm
            .bind(onNext: { [weak self] count in
                self?.setNotiStyle(count)
                self?.notificationButtonTap()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.reloadInsights
            .bind(onNext: { [weak self] in
                self?.insightListView.insightCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        
        view.backgroundColor = .gray700
        
        seedPlusButton.do {
            $0.setImage(ImageLiterals.Home.btn_add_seed, for: .normal)
        }
        
        notificationView.do {
            $0.isHidden = true
        }
        
        insightListEmptyView.do {
            $0.isHidden = true
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        
        view.addSubviews(homeCaveView, insightListView, insightEmptyView, notificationView, seedPlusButton, insightListEmptyView)
        
        homeCaveView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(173)
        }
        
        insightListView.snp.makeConstraints {
            $0.top.equalTo(homeCaveView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        seedPlusButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(seedPlusBottomInset() + 18)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        notificationView.snp.makeConstraints {
            $0.top.equalTo(homeCaveView.notificationButton.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(18)
            $0.width.equalTo(168)
            $0.height.equalTo(112)
        }
        
        insightEmptyView.snp.makeConstraints {
            $0.top.equalTo(homeCaveView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        insightListEmptyView.snp.makeConstraints {
            $0.top.equalTo(insightListView.scrapButton.snp.bottom).offset(80)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(165)
            $0.height.equalTo(180)
        }
    }
    
    // MARK: - Methods
    
    override func setDelegates() {
        longPressGesture.delegate = self
    }
    
    override func setRegister() {
        homeCaveView.caveCollectionView.register(CaveCollectionViewCell.self, forCellWithReuseIdentifier: CaveCollectionViewCell.className)
        insightListView.insightCollectionView.register(InsightListCollectionViewCell.self, forCellWithReuseIdentifier: InsightListCollectionViewCell.className)
    }
}

extension HomeViewController {
    
    // MARK: - Methods
    
    private func seedPlusBottomInset() -> CGFloat {
        return 49 + self.safeAreaBottomInset()
    }
    
    private func addGesture() {
        insightListView.insightCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    func presentToHalfModalViewController(_ indexPath: IndexPath) {
        let insightTapVC = InsightTapBottomSheet(viewModel: viewModel)
        insightTapVC.modalPresentationStyle = .overFullScreen
        insightTapVC.indexPath = indexPath
        present(insightTapVC, animated: true)
    }
    
    // 인사이트 업데이트
    func updateInsightList() {
        if let selectedItems = insightListView.insightCollectionView.indexPathsForSelectedItems {
            for indexPath in selectedItems {
                insightListView.insightCollectionView.deselectItem(at: indexPath, animated: false)
            }
        }
        self.insightListView.insightCollectionView.reloadData()
    }
    
    private func setNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearNotification(_:)),
            name: Notification.Name(I18N.Component.Identifier.deSelectNoti),
            object: nil)
    }
    
    private func pushToInsightDetail(at indexPath: IndexPath) {
        insightListView.insightCollectionView.deselectItem(at: indexPath, animated: false)
        if let cell = insightListView.insightCollectionView.cellForItem(at: indexPath) as? InsightListCollectionViewCell {
            if cell.isLock {
                view.addSubview(unLockAlertView)
                unLockAlertView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                self.lockSeedId = cell.seedId
                self.lockActionPlan = cell.hasActionPlan
            } else {
                let vc = InsightsDetailViewController(hasAnyActionPlan: cell.hasActionPlan, seedId: cell.seedId)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func scrapTypeSetting(_ type: Bool) {
        let newType = type ? false : true
        if newType {
            insightListView.scrapButton.setImage(ImageLiterals.Scrap.btn_scrap_active, for: .normal)
        } else {
            insightListView.scrapButton.setImage(ImageLiterals.Scrap.btn_scrap_default, for: .normal)
        }
        insightListView.scrapType = newType
    }
    
    private func notificationButtonTap() {
        notificationView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.notificationView.isHidden = true // 3초 후에 뷰를 숨김
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideNotificationView))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    private func pushToCaveDetailVC(caveId: Int) {
        let caveDetailVC = CaveDetailViewController(viewModel: viewModel, caveId: caveId)
        caveDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(caveDetailVC, animated: true)
    }
    
    private func presentToEmptyCaveListVC() {
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
        
//        caveListVC.indexPath = self.indexPath
        present(caveListVC, animated: true)
    }
    
    private func setNotiStyle(_ count: Int) {
        if count > 0  {
            self.notificationView.lockImage.image = ImageLiterals.Home.notification_new
            self.notificationView.notiLabel1.text = I18N.Home.notiDescription1
            self.notificationView.notiLabel2.text = "\(I18N.Home.notiDescription2)\(count)\(I18N.Home.notiDescription3)"
            self.notificationView.notiLabel1.partChange(targetString: I18N.Home.day3, textColor: .red200, font: .fontGuide(.body1_bold))
            self.notificationView.notiLabel2.partFontChange(targetString: "\(count)\(I18N.Home.count)", font: .fontGuide(.body1_bold))
        }
    }
    
    // MARK: - @objc Methods
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        if gesture.state == .began {
            // 꾹 눌림이 시작될 때 실행할 코드
            if let indexPath = insightListView.insightCollectionView.indexPathForItem(at: location) {
                if let cell = insightListView.insightCollectionView.cellForItem(at: indexPath) as? InsightListCollectionViewCell {
                    if cell.isLock {
                        return
                    } else {
                        viewModel.inputs.handleLongPress(at: indexPath)
                    }
                }
            }
        }
    }
    
    @objc func clearNotification(_ notification: Notification) {
        updateInsightList()
        if let info = notification.userInfo?[I18N.Component.Identifier.type] as? ClearInsightType {
            switch info {
            case .move:
                view.showToast(message: I18N.Component.ToastMessage.moveInsight)
            case .delete:
                view.showToast(message: I18N.Component.ToastMessage.removeInsight)
            case .none:
                return
            case .deleteCave:
                view.showToast(message: I18N.Component.ToastMessage.removeCave)
            }
        }
    }
    
    @objc func hideNotificationView(_ sender: UITapGestureRecognizer) {
        notificationView.isHidden = true
    }
}

extension HomeViewController: UIGestureRecognizerDelegate {}

extension HomeViewController: UISheetPresentationControllerDelegate {}

