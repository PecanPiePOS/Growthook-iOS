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
    // MARK: 수정 시에, 기존의 값을 주입
    func viewWillAppearWhenEditing()
}

protocol InsightsViewModelOutput {
    var networkState: BehaviorRelay<SomeNetworkStatus> { get }
    var myOwnCaves: BehaviorRelay<[InsightCaveModel]> { get }
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
    var myOwnCaves = BehaviorRelay<[InsightCaveModel]>(value: [])
    var selectedCave = BehaviorRelay<InsightCaveModel?>(value: nil)
    var selectedPeriod = BehaviorRelay<InsightPeriodModel?>(value: nil)
    var isPostingValid = BehaviorRelay<Bool>(value: false)
    var isKeyboardShown = BehaviorRelay(value: false)
    
    // MARK: - 내부 로직을 위한 프로퍼티
    private let newInsightContent = BehaviorRelay<InsightContent>(value: nil)
    private let newMemoContent = BehaviorRelay<MemoContent>(value: nil)
    private let newReferenceContent = BehaviorRelay<ReferenceContent>(value: nil)
    private let newReferenceUrlContent = BehaviorRelay<ReferenceUrlContent>(value: nil)
    private var existingData = SeedEditModel(caveName: "", insight: "", memo: "", source: "", url: "")
    
    private let isNewInsightValid = BehaviorRelay(value: false)
    private let isCaveSelectedValid = BehaviorRelay(value: false)
    private let isNewReferenceValid = BehaviorRelay(value: false)
    private let isPeriodValid = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    var inputs: InsightsViewModelInput { return self }
    var outputs: InsightsViewModelOutput { return self }
    
    // MARK: - Life Cycle
    init() {
        // TODO: memberId 여기서 찍어야함 - 임시로 4로 찍어놓음
        
        InsightsDetailService.getAllCaves(memberId: 4)
            .subscribe(onNext: { [weak self] caves in
                guard let self else { return }
                let caveModel: [InsightCaveModel] = caves.map { .init(caveId: $0.caveId, caveTitle: $0.caveName) }
                self.myOwnCaves.accept(caveModel)
            }, onError: { error in
                print(error)
                self.myOwnCaves.accept([])
            })
            .disposed(by: disposeBag)

        bindValidation()
    }
    
    init(isEditing: Bool = true, seedEditModel: SeedEditModel) {
        self.existingData = seedEditModel
        // TODO: memberId 여기서 찍어야함 - 임시로 4로 찍어놓음
        InsightsDetailService.getAllCaves(memberId: 4)
            .subscribe(onNext: { [weak self] caves in
                guard let self else { return }
                let caveModel: [InsightCaveModel] = caves.map { .init(caveId: $0.caveId, caveTitle: $0.caveName) }
                self.myOwnCaves.accept(caveModel)
            }, onError: { error in
                print(error)
                self.myOwnCaves.accept([])
            })
            .disposed(by: disposeBag)

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
    
    func viewWillAppearWhenEditing() {
        addInsight(content: existingData.insight)
        addReference(content: existingData.source)
        selectGoalPeriodToAdd(of: .init(periodMonthAsInteger: 1, periodTitle: "수정 불가"))
        if !existingData.memo.isEmpty {
            addMemo(content: existingData.memo)
        }
        
        if !existingData.url.isEmpty {
            addReferenceUrl(content: existingData.url)
        }
        
        if let existingCave = myOwnCaves.value.first(where: {
            $0.caveTitle == existingData.caveName
        }) {
            selectCaveToAdd(of: existingCave)
        }
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
                print("000", isInsightValid, isCaveValid, isReferenceValid, isPeriodValid)
                return isInsightValid && isCaveValid && isReferenceValid && isPeriodValid
            }
            .bind(to: isPostingValid)
            .disposed(by: disposeBag)
    }
    
    func fetchModifiedInsight() -> InsightEditRequest? {
        if let selectedCaveId = selectedCave.value?.caveId,
           let insight = newInsightContent.value,
           let source = newReferenceContent.value
        {
            let newInsight = InsightEditRequest(insight: insight, source: source, memo: newMemoContent.value, url: newReferenceUrlContent.value)
            return newInsight
        } else {
            print("❗️ This shouldn't be nil!!")
            return nil
        }
    }
    
    func setKeyboardSetting(isShown: Bool) {
        isKeyboardShown.accept(isShown)
    }
}
