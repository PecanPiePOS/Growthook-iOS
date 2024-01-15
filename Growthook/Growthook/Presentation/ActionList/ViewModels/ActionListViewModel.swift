//
//  ActionListViewModel.swift
//  Growthook
//
//  Created by 천성우 on 11/16/23.
//

import RxCocoa
import RxSwift
import Moya

protocol ActionListViewModelInput {
    func didTapInProgressButton()
    func didTapCompletedButton()
    func didTapInprogressScrapButton()
    func didTapCompleteScrapButton()
    func didTapSeedButton()
    func didTapReviewButton(with actionPlanId: Int)
    func setReviewText(with value: String)
    func didTapCancelButtonInBottomSheet()
    func didTapSaveButtonInBottomSheet()
    func didTapCheckButtonInAcertView()
    func didTapCancelButtonInBottomSheetWithPost(with actionPlanId: Int)
    func didTapCancelButtonWithPatch(with actionPlanId: Int)
}

protocol ActionListViewModelOutput {
    var titleText: Driver<String> { get }
    var titlePersent: BehaviorRelay<String> { get }
    var selectedIndex: BehaviorRelay<Int> { get }
    var doingActionList: BehaviorRelay<[ActionListDoingResponse]> { get }
    var finishedActionList: BehaviorRelay<[ActionListFinishedResponse]> { get }
    var isReviewEntered: Driver<Bool> { get }
    var reviewTextCount: Driver<String> { get }
    var reviewDetail: BehaviorRelay<ActionListReviewDetailResponse> { get }
}

protocol ActionListViewModelType {
    var inputs: ActionListViewModelInput { get }
    var outputs: ActionListViewModelOutput { get }
}

final class ActionListViewModel: ActionListViewModelInput, ActionListViewModelOutput, ActionListViewModelType {
    
    var selectedIndex: BehaviorRelay<Int> = BehaviorRelay(value: 1)
    var doingActionList: BehaviorRelay<[ActionListDoingResponse]> = BehaviorRelay<[ActionListDoingResponse]>(value: [])
    var finishedActionList: BehaviorRelay<[ActionListFinishedResponse]> = BehaviorRelay<[ActionListFinishedResponse]>(value: [])
    var reviewText = BehaviorRelay<String>(value: "")
    var titlePersent: BehaviorRelay<String> = BehaviorRelay(value: "")
    var reviewDetail: BehaviorRelay<ActionListReviewDetailResponse> = BehaviorRelay<ActionListReviewDetailResponse>(value: ActionListReviewDetailResponse.actionListReviewDetailDummy())
    private let disposeBag = DisposeBag()
        
    var inputs: ActionListViewModelInput { return self }
    var outputs: ActionListViewModelOutput { return self }
    
    
    var titleText: Driver<String> {
        return .just("Action List")
    }
    
    var isReviewEntered: Driver<Bool> {
        return reviewText.asDriver()
            .map { text in
                return !(text.isEmpty || text == "액션 플랜을 달성하며 어떤 것을 느꼈는지 작성해보세요")
            }
    }
    
    
    var reviewTextCount: Driver<String> {
        return reviewText.asDriver()
            .map { "\($0.count)/300" }
    }
    
    
    init() {
        self.getActionListPercent()
        self.getFinishedActionList()
        self.getDoingActionList()
    }
    
    func didTapInProgressButton() {
        selectedIndex.accept(1)
        getDoingActionList()
        getActionListPercent()
    }
    
    func didTapCompletedButton() {
        selectedIndex.accept(0)
        getFinishedActionList()
        getActionListPercent()
    }
    
    func didTapInprogressScrapButton() {
        print("진행중 탭 에서스크랩만 보기 버튼이 탭 되었습니다")
    }
    
    func didTapCompleteScrapButton() {
        print("완료 탭 에서 스크랩만 보기 버튼이 탭 되었습니다")
    }
    
    func didTapSeedButton() {
        print("씨앗보기 버튼이 탭 되었습니다")
    }
    
    func didTapReviewButton(with actionPlanId: Int) {
        print("리뷰보기 버튼이 탭 되었습니다")
        // 리뷰 get API 연결
        getpostActionListReview(actionPlanId: actionPlanId)
    }
    
    func setReviewText(with value: String) {
        reviewText.accept(value)
    }
    
    func didTapCancelButtonInBottomSheet() {
        selectedIndex.accept(0)
        getActionListPercent()
    }
    
    func didTapSaveButtonInBottomSheet() {
        selectedIndex.accept(0)
        getActionListPercent()
    }
    
    func didTapCheckButtonInAcertView() {
        getFinishedActionList()
        getActionListPercent()
    }
    
    func didTapCancelButtonWithPatch(with actionPlanId: Int) {
        patchActionPlanCompletion(actionPlanId: actionPlanId)
        getFinishedActionList()
        getActionListPercent()
    }
    
    func didTapCancelButtonInBottomSheetWithPost(with actionPlanId: Int) {
        postActionListReview(actionPlanId: actionPlanId)
        patchActionPlanCompletion(actionPlanId: actionPlanId)
        getFinishedActionList()
        getActionListPercent()
    }
}


extension ActionListViewModel {
    
    private func getActionListPercent() {
        ActionListService.getActionListPercent(with: 4)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.titlePersent.accept("\(data)")
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func getDoingActionList() {
        ActionListService.getDoingActionList(with: 4)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.doingActionList.accept(data)
                print("getDoingActionList accpet가 호출됩니다")
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func getFinishedActionList() {
        print("getFinishedActionList가 호출됩니다")
        ActionListService.getFinishedActionList(with: 4)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.finishedActionList.accept(data)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func patchActionPlanCompletion(actionPlanId: Int) {
        ActionListService.patchActionListCompletion(with: actionPlanId)
            .subscribe(onNext: { _ in
                print("patchActionPlanCompletion가 호출됩니다")
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func postActionListReview(actionPlanId: Int) {
        let newReview = ActionListReviewPostRequest(content: reviewText.value)
        
        ActionListService.postActionListReview(actionPlanId: actionPlanId, review: newReview)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                print("review작성에 성공했습니다")
                print("리뷰 내용: \(newReview)")
            }, onError: { [weak self] error in
                guard let self else { return }
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func getpostActionListReview(actionPlanId: Int) {
        print("getpostActionListReview가 호출됩니다")
        ActionListService.getActionListReview(with: actionPlanId)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.reviewDetail.accept(data)
                print(data)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}

