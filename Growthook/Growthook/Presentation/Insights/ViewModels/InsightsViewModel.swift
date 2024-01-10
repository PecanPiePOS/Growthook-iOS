//
//  InsightsViewModel.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 11/12/23.
//

import UIKit

import RxCocoa
import RxSwift

// TODO: Renaming 이 필요함
enum SomeNetworkStatus {
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
    // MARK: 네트워크 호출
    func postNewInsight()
    // MARK: Lazy 값 주입
    func setPeriodDataWhenSheetIsPresented()
    // MARK: 네트워크 Error 처리
    func cancelErrorAlert()
}

protocol InsightsViewModelOutput {
    var networkState: BehaviorRelay<SomeNetworkStatus> { get }
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
    var networkState = BehaviorRelay<SomeNetworkStatus>(value: .normal)
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
            .init(caveId: 48, caveTitle: "Cave11"),
            .init(caveId: 49, caveTitle: "Cave12"),
            .init(caveId: 50, caveTitle: "Cave13"),
            .init(caveId: 51, caveTitle: "Cave14"),
            .init(caveId: 52, caveTitle: "Cave15")
        ])
        
        bindValidation()
    }
    
    // MARK: - Inputs
    func postNewInsight() {
        /// Network 가 끊어졌을 때
        if NetworkManager.isNetworkConnected() == false {
            networkState.accept(.networkLost)
            return
        }
        
        if let selectedCaveId = selectedCave.value?.caveId,
           let insight = newInsightContent.value,
           let source = newReferenceContent.value,
           let period = selectedPeriod.value?.periodMonthAsInteger
        {
            networkState.accept(.loading)
            let newInsight = InsightPostRequest(insight: insight, source: source, memo: newMemoContent.value, url: newReferenceUrlContent.value, goalMonth: period)
            InsightsService.postNewInsight(caveId: selectedCaveId, of: newInsight)
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    self.networkState.accept(.done)
                }, onError: { [weak self] error in
                    guard let self else { return }
                    self.networkState.accept(.error(error))
                })
                .disposed(by: disposeBag)
        } else {
            /// 보내는 모델의 문제가 있을 때
            // 여기는 나중에 필요하면 추가하겠습니다.
        }
    }
    
    func addInsight(content: String) {
        let isEditCancelledWithNoneInput: Bool = content == I18N.CreateInsight.insightTextViewPlaceholder
        /// TextView 에 Input 이 없을 때, placeholder 가 text 로 들어온다.
        /// 해당 상황에서는 nil 이어야 한다.
        if isEditCancelledWithNoneInput != false {
            newInsightContent.accept(nil)
            return
        }
        let modifiedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if !modifiedContent.isEmpty {
            newInsightContent.accept(modifiedContent)
        } else {
            newInsightContent.accept(nil)
        }
    }
    
    func addMemo(content: String) {
        let isEditCancelledWithNoneInput: Bool = content == I18N.CreateInsight.memoTextViewPlaceholder

        if isEditCancelledWithNoneInput != false {
            newMemoContent.accept(nil)
            return
        }
        let modifiedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if !modifiedContent.isEmpty {
            newMemoContent.accept(modifiedContent)
        } else {
            newMemoContent.accept(nil)
        }
    }
    
    func selectCaveToAdd(of cave: InsightCaveModel) {
        selectedCave.accept(cave)
    }
    
    func addReference(content: String) {
        let modifiedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if !modifiedContent.isEmpty {
            newReferenceContent.accept(modifiedContent)
        } else {
            newReferenceContent.accept(nil)
        }
    }
    
    func addReferenceUrl(content: String) {
        let modifiedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if !modifiedContent.isEmpty {
            newReferenceUrlContent.accept(modifiedContent)
        } else {
            newReferenceUrlContent.accept(nil)
        }
    }
    
    func selectGoalPeriodToAdd(of period: InsightPeriodModel) {
        selectedPeriod.accept(period)
    }
    
    func setPeriodDataWhenSheetIsPresented() {
        if availablePeriodList.isEmpty {
            availablePeriodList = PeriodModel.periodSetToSelect
        }
    }
    
    func cancelErrorAlert() {
        networkState.accept(.normal)
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
            .map { $0?.periodMonthAsInteger != nil }
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
