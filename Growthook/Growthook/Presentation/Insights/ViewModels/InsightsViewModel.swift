//
//  InsightsViewModel.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 11/12/23.
//

import UIKit

import RxCocoa
import RxSwift

enum InsightsViewNetworkStatus {
    case normal
    case networkLost
    case loading
    case error(_: Error)
    case done
}

protocol InsightsViewModelInput {
    // MARK: 값 입력
    func addInsight(content: String)
    func addMemo(content: String)
    func selectCaveToAdd(of cave: InsightCaveModel)
    func addReference(content: String)
    func addReferenceUrl(content: String)
    func selectGoalPeriodToAdd(of period: InsightPeriodModel)
    func resetSelectedCave()
    // MARK: 네트워크 호출
    func postNewInsight(with newInsight: InsightPostRequest)
    // MARK: Lazy 값 주입
    func setPeriodDataWhenSheetIsPresented()
    // MARK: 네트워크 Error 처리
    func cancelErrorAlert()
}

protocol InsightsViewModelOutput {
    var networkStatus: BehaviorRelay<InsightsViewNetworkStatus> { get }
    var myOwnCaves: Observable<[InsightCaveModel]> { get }
    var selectedCave: BehaviorRelay<InsightCaveModel?> { get }
    var availablePeriodList: [InsightPeriodModel] { get }
    var selectedPeriod: BehaviorRelay<InsightPeriodModel?> { get }
    var isPostingValid: BehaviorRelay<Bool> { get }
}

protocol InsightsViewModelType {
    var inputs: InsightsViewModelInput { get }
    var outputs: InsightsViewModelOutput { get }
}

final class InsightsViewModel: InsightsViewModelOutput, InsightsViewModelInput, InsightsViewModelType {
    
    // MARK: - Typealias 지정
    typealias InsightContent = String?
    typealias MemoContent = String?
    typealias ReferenceContent = String?
    typealias ReferenceUrlContent = String?
    
    // MARK: - Outputs
    var networkStatus = BehaviorRelay<InsightsViewNetworkStatus>(value: .normal)
    var availablePeriodList: [InsightPeriodModel] = []
    var myOwnCaves: Observable<[InsightCaveModel]>
    var selectedCave = BehaviorRelay<InsightCaveModel?>(value: nil)
    var selectedPeriod = BehaviorRelay<InsightPeriodModel?>(value: nil)
    var isPostingValid = BehaviorRelay<Bool>(value: false)
    
    // MARK: - 내부 로직을 위한 프로퍼티
    private let newInsightContent = BehaviorRelay<InsightContent>(value: nil)
    private let newMemoContent = BehaviorRelay<MemoContent>(value: nil)
    private let newReferenceContent = BehaviorRelay<ReferenceContent>(value: nil)
    private let newReferenceUrlContent = BehaviorRelay<ReferenceUrlContent>(value: nil)
    
    private let isNewInsightValid = BehaviorRelay(value: false)
    private let isCaveSelectedValid = BehaviorRelay(value: false)
    private let isNewReferenceValid = BehaviorRelay(value: false)
    private let isPeriodValid = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    var inputs: InsightsViewModelInput { return self }
    var outputs: InsightsViewModelOutput { return self }
    
    // MARK: - Life Cycle
    init() {
        // TODO: 내 동굴의 값을 API 를 통해 받아와야 하는지, 내부에 저장한 값을 가저올지 정해야 합니다. + 시점도 정해야 합니다.
        myOwnCaves = Observable.just([
            .init(caveId: 0, caveTitle: "Cave11"),
            .init(caveId: 1, caveTitle: "Cave12"),
            .init(caveId: 2, caveTitle: "Cave13"),
            .init(caveId: 3, caveTitle: "Cave14"),
            .init(caveId: 4, caveTitle: "Cave15"),
            .init(caveId: 5, caveTitle: "Cave16"),
            .init(caveId: 6, caveTitle: "Cave17")
        ])
        
        bindValidation()
    }
    
    // MARK: - Inputs
    func postNewInsight(with newInsight: InsightPostRequest) {
        /// Network 가 끊어졌을 때
        if NetworkManager.isNetworkConnected() == false {
            networkStatus.accept(.networkLost)
            return
        }
        
        if let selectedCaveId = selectedCave.value?.caveId,
           let insight = newInsightContent.value,
           let source = newReferenceContent.value,
           let period = selectedPeriod.value?.periodMonthAsInteger
        {
            networkStatus.accept(.loading)
            let newInsight = InsightPostRequest(insight: insight, source: source, memo: newMemoContent.value, url: newReferenceUrlContent.value, goalMonth: period)
            InsightsService.postNewInsight(caveId: selectedCaveId, of: newInsight)
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    self.networkStatus.accept(.done)
                }, onError: { [weak self] error in
                    guard let self else { return }
                    self.networkStatus.accept(.error(error))
                })
                .disposed(by: disposeBag)
        } else {
            /// 보내는 모델의 문제가 있을 때
            // 여기는 나중에 필요하면 추가하겠습니다.
        }
    }
    
    func addInsight(content: String) {
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            newInsightContent.accept(content)
        }
    }
    
    func addMemo(content: String) {
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            newMemoContent.accept(content)
        }
    }
    
    func selectCaveToAdd(of cave: InsightCaveModel) {
        selectedCave.accept(cave)
    }
    
    func addReference(content: String) {
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            newReferenceContent.accept(content)
        }
    }
    
    func addReferenceUrl(content: String) {
        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            newReferenceUrlContent.accept(content)
        }
    }
    
    func selectGoalPeriodToAdd(of period: InsightPeriodModel) {
        selectedPeriod.accept(period)
    }
    
    func resetSelectedCave() {
        selectedCave.accept(nil)
    }
    
    func setPeriodDataWhenSheetIsPresented() {
        availablePeriodList = PeriodModel.periodSetToSelect
    }
    
    func cancelErrorAlert() {
        networkStatus.accept(.normal)
    }
}

extension InsightsViewModel {
    
    // MARK: - Validation Helper
    private func bindValidation() {
        newInsightContent
            .map { $0 != nil }
            .bind(to: isNewInsightValid)
            .disposed(by: disposeBag)
        
        selectedCave
            .map { $0 != nil }
            .bind(to: isCaveSelectedValid)
            .disposed(by: disposeBag)
        
        newReferenceContent
            .map { $0 != nil }
            .bind(to: isNewReferenceValid)
            .disposed(by: disposeBag)
        
        selectedPeriod
            .map { $0 != nil }
            .bind(to: isPeriodValid)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isNewInsightValid, isCaveSelectedValid, isNewReferenceValid, isPeriodValid)
            .map { isInsightValid, isCaveValid, isReferenceValid, isPeriodValid in
                return isInsightValid && isCaveValid && isReferenceValid && isPeriodValid
            }
            .bind(to: isPostingValid)
            .disposed(by: disposeBag)
    }
}
