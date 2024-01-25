//
//  ActionListViewModel.swift
//  Growthook
//
//  Created by 천성우 on 11/16/23.
//

import UIKit

import RxCocoa
import RxSwift
import Moya

protocol ActionListViewModelInput {
    func didTapInProgressButton()
    func didTapCompletedButton()
    func didTapInprogressOnlyScrapButton()
    func didTapInprogressScrapButton(with actionPlanId: Int)
    func didTapCompleteOnlyScrapButton()
    func didTapCompleteScrapButton(with actionPlanId: Int)
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
    var memberId: Int = UserDefaults.standard.integer(forKey: I18N.Auth.memberId)
    
    var inputs: ActionListViewModelInput { return self }
    var outputs: ActionListViewModelOutput { return self }
    
    
    var titleText: Driver<String> {
        return .just(UserDefaults.standard.string(forKey: I18N.Auth.nickname) ?? "")
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
        self.getActionListPercent(mamberId: memberId)
        self.getFinishedActionList(mamberId: memberId)
        self.getDoingActionList(mamberId: memberId)

    }
    
    func didTapInProgressButton() {
        selectedIndex.accept(1)
        getDoingActionList(mamberId: memberId)
        getActionListPercent(mamberId: memberId)
    }
    
    func didTapCompletedButton() {
        selectedIndex.accept(0)
        getFinishedActionList(mamberId: memberId)
        getActionListPercent(mamberId: memberId)
    }
    
    func didTapInprogressOnlyScrapButton() {
        print("진행중 탭 에서스크랩만 보기 버튼이 탭 되었습니다")
        getDoingActionList(mamberId: memberId)
    }
    
    func didTapCompleteOnlyScrapButton() {
        print("완료 탭 에서 스크랩만 보기 버튼이 탭 되었습니다")
        getFinishedActionList(mamberId: memberId)
    }
    
    func didTapInprogressScrapButton(with actionPlanId: Int) {
        print("진행중 탭에서 스크랩 버튼이 탭 되었습니다")
        patchACtionListScrap(actionPlanId: actionPlanId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.getDoingActionList(mamberId: self.memberId)
            self.getActionListPercent(mamberId: self.memberId)
        }
    }
    
    func didTapCompleteScrapButton(with actionPlanId: Int) {
        print("완료 탭에서 스크랩 버튼이 탭 되었습니다")
        patchACtionListScrap(actionPlanId: actionPlanId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.getFinishedActionList(mamberId: self.memberId)
            self.getActionListPercent(mamberId: self.memberId)
        }
    }
    
    func didTapSeedButton() {
        print("씨앗보기 버튼이 탭 되었습니다")
        // 씨앗 보기 화면 전환 코드 필요
    }
    
    func didTapReviewButton(with actionPlanId: Int) {
        getActionListReview(actionPlanId: actionPlanId)
    }
    
    func setReviewText(with value: String) {
        reviewText.accept(value)
    }
    
    func didTapCancelButtonInBottomSheet() {
        selectedIndex.accept(0)
        getActionListPercent(mamberId: memberId)
    }
    
    func didTapSaveButtonInBottomSheet() {
        selectedIndex.accept(0)
        getActionListPercent(mamberId: memberId)
    }
    
    func didTapCheckButtonInAcertView() {
        getFinishedActionList(mamberId: memberId)
        getActionListPercent(mamberId: memberId)
    }
    
    func didTapCancelButtonWithPatch(with actionPlanId: Int) {
        patchActionPlanCompletion(actionPlanId: actionPlanId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.getFinishedActionList(mamberId: self.memberId)
            self.getActionListPercent(mamberId: self.memberId)
        }
    }

    
    func didTapCancelButtonInBottomSheetWithPost(with actionPlanId: Int) {
        postActionListReview(actionPlanId: actionPlanId)
        patchActionPlanCompletion(actionPlanId: actionPlanId)
        getFinishedActionList(mamberId: memberId)
        getActionListPercent(mamberId: memberId)
    }
}

extension ActionListViewModel {
    
    private func getActionListPercent(mamberId: Int) {
        ActionListService.getActionListPercent(with: mamberId)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.titlePersent.accept("\(data)")
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func getDoingActionList(mamberId: Int) {
        ActionListService.getDoingActionList(with: mamberId)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.doingActionList.accept(data)
                print("getDoingActionList accpet가 호출됩니다")
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func getFinishedActionList(mamberId: Int) {
        print("getFinishedActionList가 호출됩니다")
        ActionListService.getFinishedActionList(with: mamberId)
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
    
    private func getActionListReview(actionPlanId: Int) {
        print("getActionListReview가 호출됩니다")
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
    
    
    private func patchACtionListScrap(actionPlanId: Int) {
        ActionListService.patchACtionListScrap(with: actionPlanId)
            .subscribe(onNext: { _ in
                print("patchACtionListScrap가 호출됩니다")
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}

