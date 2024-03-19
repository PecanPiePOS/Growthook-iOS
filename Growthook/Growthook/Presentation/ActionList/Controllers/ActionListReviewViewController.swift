//
//  ActionListReviewViewController.swift
//  Growthook
//
//  Created by 천성우 on 11/27/23.
//

import UIKit

import Moya
import RxCocoa
import RxSwift
import SnapKit
import Then

final class ActionListReviewViewController: BaseViewController {
    
    private var viewModel: ActionListViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let navigationBar = CustomNavigationBar()
    private let titleLabel = UILabel()
    private let scrapButton = UIButton()
    private let reviewTextView = UITextViewWithTintedWhenEdited(placeholder: "할 일을 달성하며 어떤 것을 느꼈는지 작성해보세요", maxLength: 300)
    private let writtenDateLabel = UILabel()
    
    // MARK: - Properties
    
    private var actionPlanId: Int = 0
    private var actionPlanisScraped: Bool = true
    
    
    // MARK: - Initializer
    
    init(viewModel: ActionListViewModel, actionPlanId: Int, actionPlanisScraped: Bool){
        self.viewModel = viewModel
        self.actionPlanId = actionPlanId
        self.actionPlanisScraped = actionPlanisScraped
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func bindViewModel() {
        scrapButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.didTapReviewScrapButton(with: self.actionPlanId, with: self.actionPlanisScraped)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.reviewDetail
            .subscribe(onNext: { [weak self] data in
                self?.setReviewDetail(reviewData: data)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showToastToggle
            .bind(onNext: { [weak self] index in
                if index == 1 {
                    self?.showToast()
                    self?.toggleScrapImage(binary: 1)
                } else if index == 0 {
                    self?.showCancelToast()
                    self?.toggleScrapImage(binary: 0)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components Property
    
    override func setStyles() {
        view.backgroundColor = .gray600
        
        navigationBar.do {
            $0.backgroundColor = .gray600
            $0.isTitleViewIncluded = true
            $0.isTitleLabelIncluded = "느낀점"
            $0.isBackButtonIncluded = true
            $0.setupBackButtonTarget()
            $0.backButtonAction = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        titleLabel.do {
            $0.font = .fontGuide(.body1_bold)
            $0.textColor = .white000
        }
        
        reviewTextView.do {
            $0.isEditable = false
            $0.textColor = .white000
        }
        
        scrapButton.do {
            $0.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
        }
        
        writtenDateLabel.do {
            $0.text = "0000.00.00"
            $0.font = .fontGuide(.detail1_reg)
            $0.textColor = .gray300
        }
    }
    
    // MARK: - Layout Helper
    
    override func setLayout() {
        view.addSubviews(navigationBar, titleLabel, scrapButton, reviewTextView, writtenDateLabel)
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaTopInset())
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(SizeLiterals.Screen.screenHeight * 48 / 812)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(18)
        }
        
        scrapButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(48)
        }
        
        reviewTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(339)
            $0.height.equalTo(170)
        }
        
        writtenDateLabel.snp.makeConstraints {
            $0.top.equalTo(reviewTextView.snp.bottom).offset(4)
            $0.trailing.equalTo(reviewTextView.snp.trailing).inset(4)
        }
    }
    
    // MARK: - Methods
    
    func setReviewDetail(reviewData: ActionListReviewDetailResponse) {
        titleLabel.text = reviewData.actionPlan
        reviewTextView.text = reviewData.content
        writtenDateLabel.text = reviewData.reviewDate
        switch reviewData.isScraped {
        case false:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
        case true:
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
        }
    }
    
    private func showToast() {
        view.showScrapToast(message: I18N.Component.ToastMessage.scrap)
    }
    
    private func showCancelToast() {
        view.showScrapToast(message: I18N.Component.ToastMessage.unScrap)
    }
    
    private func toggleScrapImage(binary: Int) {
        if binary == 1 {
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_on, for: .normal)
        } else {
            scrapButton.setImage(ImageLiterals.Home.btn_scrap_light_off, for: .normal)
        }
    }
    
    // MARK: - @objc Methods
    
    @objc
    private func popActionListReviewViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
