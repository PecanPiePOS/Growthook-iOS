//
//  InprogressViewController.swift
//  Growthook
//
//  Created by 천성우 on 11/18/23.
//

import UIKit

import Moya
import RxCocoa
import RxSwift
import SnapKit
import Then

protocol NotificationActionListVC: AnyObject {
    func moveToCompletePageByCancelButton()
    func moveToCompletePageBySaveButton()
}

final class InprogressViewController: BaseViewController, NotificationDismissBottomSheet {
    
    private var viewModel: ActionListViewModel
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let scrapButton = UIButton()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyView = EmptyView(frame: .zero, emptyType: .inprogress)
    
    // MARK: - Properties
    
    weak var delegate: NotificationActionListVC?
    weak var pushDelegate: PushInsightsDetailViewController?
    private var isShowingScrappedData = false
    private var isPresentingBottomSheet = false
    var indexPath: IndexPath? = nil
    
    // MARK: - Initializer
    
    init(viewModel: ActionListViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindViewModel() {
        scrapButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.didTapInprogressOnlyScrapButton()
                self.isShowingScrappedData.toggle()
                self.tableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.doingActionList
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                if data.isEmpty {
                    self.tableView.backgroundView?.isHidden = false
                    self.tableView.reloadData()
                } else {
                    self.tableView.backgroundView?.isHidden = true
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        view.backgroundColor = .gray700
        
        scrapButton.do {
            $0.setImage(ImageLiterals.Scrap.btn_scrap_default, for: .normal)
        }
        
        tableView.do {
            $0.showsVerticalScrollIndicator = false
            $0.separatorStyle = .none
            $0.register(ActionListTableViewCell.self, forCellReuseIdentifier: "actionListTableCell")
            $0.delegate = self
            $0.dataSource = self
            $0.backgroundColor = .gray700
            $0.backgroundView = emptyView
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        view.addSubviews(scrapButton, tableView)
        
        scrapButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.trailing.equalToSuperview().inset(18)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(scrapButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
    private func presentToBottomSheet(actionPlanId: Int) {
        guard !isPresentingBottomSheet else {
            return
        }
        isPresentingBottomSheet = true
        
        let bottomSheetVC = ActionListBottomSheetViewController(actionPlanId: actionPlanId, viewModel: viewModel)
        bottomSheetVC.delegate = self
        
        self.present(bottomSheetVC, animated: true) {
            self.isPresentingBottomSheet = false
        }
    }
    
    private func getScrappedActionList() -> [ActionListDoingResponse] {
        return viewModel.outputs.doingActionList.value.filter { $0.isScraped == true }
    }
    
    func pushToInsightsDetailViewControllerInInprogressViewController(seedId: Int) {
        pushDelegate?.didTapSeedButtonInInprogressViewController(seedId : seedId)
    }
    
    func notificationDismissInCancelButton() {
        print("notificationDismiss in InprogressVC by cancelButton")
        delegate?.moveToCompletePageByCancelButton()
    }
    
    func notificationDismissInSaveButton() {
        print("notificationDismiss in InprogressVC by saveButton")
        delegate?.moveToCompletePageBySaveButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension InprogressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingScrappedData {
            scrapButton.setImage(ImageLiterals.Scrap.btn_scrap_active, for: .normal)
            return getScrappedActionList().count
        } else {
            scrapButton.setImage(ImageLiterals.Scrap.btn_scrap_default, for: .normal)
            return viewModel.outputs.doingActionList.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "actionListTableCell", for: indexPath) as! ActionListTableViewCell
        let model: ActionListDoingResponse
        
        if isShowingScrappedData {
            model = getScrappedActionList()[indexPath.row]
        } else {
            model = viewModel.outputs.doingActionList.value[indexPath.row]
        }
        cell.configure(model)
        cell.disposeBag = DisposeBag()
        
        cell.scrapButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                    self.viewModel.inputs.didTapInprogressScrapButton(with: cell.actionPlanId, with: cell.isScraped)
            }
            .disposed(by: cell.disposeBag)
        
        cell.seedButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.didTapSeedButton()
                self.pushToInsightsDetailViewControllerInInprogressViewController(seedId: cell.seedId)
            }
            .disposed(by: cell.disposeBag)
        
        cell.completButton.rx.tap
            .bind { [weak self]  in
                guard let self else { return }
                self.presentToBottomSheet(actionPlanId: cell.actionPlanId)
            }
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}
