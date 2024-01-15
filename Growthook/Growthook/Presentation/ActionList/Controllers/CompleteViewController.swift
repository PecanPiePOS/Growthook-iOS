//
//  CompleteViewController.swift
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

final class CompleteViewController: BaseViewController {
    
    private var viewModel: ActionListViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let scrapButton = ScrapOnlyButton()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Properties
    
    weak var delegate: PushToActionListReviewViewController?
    private var isShowingScrappedData = false
    
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
                self.viewModel.inputs.didTapCompleteScrapButton()
                self.isShowingScrappedData.toggle()
                self.tableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.finishedActionList
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        view.backgroundColor = .gray700
        
        tableView.do {
            $0.showsVerticalScrollIndicator = false
            $0.separatorStyle = .none
            $0.register(ActionListCompleteTableViewCell.self, forCellReuseIdentifier: "completeActionListTableCell")
            $0.delegate = self
            $0.dataSource = self
            $0.backgroundColor = .gray700
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
            $0.top.equalTo(scrapButton.snp.bottom).offset(13)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
    private func getScrappedActionList() -> [ActionListFinishedResponse] {
        return viewModel.outputs.finishedActionList.value.filter { $0.isScraped == true }
    }
    
    // MARK: - @objc Methods
    
    @objc func buttonTapped() {
        delegate?.didTapButtonInCompleteViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension CompleteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingScrappedData {
            return getScrappedActionList().count
        } else {
            return viewModel.outputs.finishedActionList.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "completeActionListTableCell", for: indexPath) as! ActionListCompleteTableViewCell
        let model: ActionListFinishedResponse
        if isShowingScrappedData {
            model = getScrappedActionList()[indexPath.row]
        } else {
            model = viewModel.outputs.finishedActionList.value[indexPath.row]
        }
        
        cell.configure(model)
        cell.disposeBag = DisposeBag()
        
        cell.seedButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.didTapSeedButton()
            }
            .disposed(by: cell.disposeBag)
        
        cell.reviewButton.rx.tap
            .bind { [weak self]  in
                guard let self else { return }
                self.viewModel.inputs.didTapReviewButton()
                self.buttonTapped()
            }
            .disposed(by: cell.disposeBag)

        return cell
    }
}
