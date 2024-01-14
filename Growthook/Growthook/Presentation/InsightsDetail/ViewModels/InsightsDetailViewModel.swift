//
//  InsightsDetailViewModel.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/14/24.
//

import UIKit

import RxCocoa
import RxSwift

enum InsightsDetailToastType {
    case none
    
    case scrapToast(success: Bool)
    case moveSeedToast(success: Bool)
    case deleteSeedToast(success: Bool)
    case editSeedToast(success: Bool)
    
    case deleteActionPlan(success: Bool)
    case editActionPlan(success: Bool)
    case createActionPlan(success: Bool)
    
    var toastMessage: String {
        switch self {
        case .none:
            return ""
        case .scrapToast(let success):
            if success != false { return "스크랩 완료" } else { return "실패했어요" }
        case .moveSeedToast(let success):
            if success != false { return "씨앗을 옮겨 심었어요" } else { return "실패했어요" }
        case .deleteSeedToast(let success):
            if success != false { return "씨앗이 삭제되었어요" } else { return "실패했어요" }
        case .editSeedToast(let success):
            if success != false { return "씨앗이 수정되었어요" } else { return "실패했어요" }
        case .deleteActionPlan(let success):
            if success != false { return "액션이 삭제되었어요" } else { return "실패했어요" }
        case .editActionPlan(let success):
            if success != false { return "액션이 수정되었어요" } else { return "실패했어요" }
        case .createActionPlan(let success):
            if success != false { return "액션을 만들었어요" } else { return "실패했어요" }
        }
    }
}

enum InsightDetailNetworkState {
    case normal
    case error(of: Error)
}

protocol InsightsDetailViewModelInput {
    func navigationBarMenuDidTap() //
    func relocateSeed(to newCaveId: Int)
    func editSeedSucceeded()
    func deleteSeedDidTap(handler: @escaping (Bool) -> Void)
    func moveSeedToOtherCave(of selectedCave: InsightCaveModel)
    
    func readMoreDidTap()
    func actionPlanMenuDidTap()
    func completeActionPlan(withReviewOf review: String?, actionPlanIdOf actionPlanId: Int, handler: @escaping (Bool) -> Void)
    func addSingleNewAction(newActionPlanText: String, handler: @escaping (Bool) -> Void)
    func editActionPlan(actionPlanId: Int, editedActionPlanText: String, handler: @escaping (Bool) -> Void)
    func deleteActionPlan(actionPlanId: Int)
    
    func hideMemoView(_ hasActionPlans: Bool)
    func resetToastStatus()
    func resetNetworkStatus()
}

protocol InsightsDetailViewModelOutput {
    var shouldHideMemoView: PublishSubject<Bool> { get }
    var toastStatus: BehaviorRelay<InsightsDetailToastType> { get }
    var networkStatus: BehaviorRelay<InsightDetailNetworkState> { get }
    
    var seedDetail: PublishSubject<SeedDetailResponsse> { get }
    var caveData: PublishSubject<[InsightCaveModel]> { get } /// Not Yet
    var actionPlans: BehaviorRelay<[InsightActionPlanResponse]> { get }
}

protocol InsightsDetailViewModelType {
    var inputs: InsightsDetailViewModelInput { get }
    var outputs: InsightsDetailViewModelOutput { get }
}

final class InsightsDetailViewModel: InsightsDetailViewModelInput, InsightsDetailViewModelOutput, InsightsDetailViewModelType {
    
    var networkStatus = BehaviorRelay<InsightDetailNetworkState>(value: .normal)
    var toastStatus = BehaviorRelay<InsightsDetailToastType>(value: .none)
    var shouldHideMemoView = PublishSubject<Bool>()
    var seedDetail = PublishSubject<SeedDetailResponsse>()
    var caveData = PublishSubject<[InsightCaveModel]>()
    var actionPlans = BehaviorRelay<[InsightActionPlanResponse]>(value: [])
    
    private let disposeBag = DisposeBag()
    private let seedId: Int
    
    var inputs: InsightsDetailViewModelInput { return self }
    var outputs: InsightsDetailViewModelOutput { return self }
 
    init(hasAnyActionPlan: Bool, seedId: Int) {
        self.shouldHideMemoView.onNext(hasAnyActionPlan)
        self.seedId = seedId
        getSeedDetail()
        getActionPlans()
    }

    func navigationBarMenuDidTap() {
        print("NavigationBar Menu Tapped")
    }
    
    func relocateSeed(to newCaveId: Int) {
        InsightsDetailService.moveSeed(withSeedOf: seedId, to: newCaveId)
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                self.toastStatus.accept(.moveSeedToast(success: true))
                self.resetToastStatus()
            }, onError: { error in
                print(error)
                self.toastStatus.accept(.moveSeedToast(success: false))
                self.resetToastStatus()
            })
            .disposed(by: disposeBag)
    }
    
    func resetToastStatus() {
        self.toastStatus.accept(.none)
    }
    
    /// 씨앗 수정 실패시에는 기존의 내용을 유지하기 위해, 에러 처리 및 화면 전환이 없습니다.
    /// toast 는 성공일 때만 띄웁니다.
    func editSeedSucceeded() {
        InsightsDetailService.getSeedDetail(seedId: seedId)
            .subscribe(onNext: { [weak self] seedDetail in
                guard let self else { return }
                self.seedDetail.onNext(seedDetail)
                self.toastStatus.accept(.editSeedToast(success: true))
                self.resetToastStatus()
            })
            .disposed(by: disposeBag)
    }
    
    /// 실패했을 때만, 해당 씨앗 조회 화면에서 toast 를 띄웁니다.
    /// 성공시에 toast 를 띄우는 것은 다른 화면입니다.
    func deleteSeedDidTap(handler: @escaping (Bool) -> Void) {
        InsightsService.deleteInsight(seedId: seedId)
            .subscribe(onNext: { response in
                handler(true)
            }, onError: { error in
                print(error)
                self.toastStatus.accept(.deleteSeedToast(success: false))
                self.resetToastStatus()
                handler(false)
            })
            .disposed(by: disposeBag)
    }
    
    func moveSeedToOtherCave(of selectedCave: InsightCaveModel) {
        InsightsDetailService.moveSeed(withSeedOf: seedId, to: selectedCave.caveId)
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                self.toastStatus.accept(.moveSeedToast(success: true))
            }, onError: { error in
                print(error)
                self.toastStatus.accept(.moveSeedToast(success: false))
            })
            .disposed(by: disposeBag)
    }
    
    func readMoreDidTap() {
        print("ReadMore Tapped")
    }
    
    func actionPlanMenuDidTap() {
        print("ActionPlan Menu Tapped")
    }
    
    func completeActionPlan(withReviewOf review: String?, actionPlanIdOf actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        InsightsDetailService.completeActionPlan(actionPlanId: actionPlanId)
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                self.getActionPlans()
                handler(true)
            }, onError: { error in
                print(error)
                handler(false)
            })
            .disposed(by: disposeBag)
        
        InsightsDetailService.postNewReviewToComplete(content: review ?? "", actionPlanId: actionPlanId)
            .subscribe(
                onNext: { _ in },
                onError: { error in
                    print(error)
                })
            .disposed(by: disposeBag)
    }
    
    func addSingleNewAction(newActionPlanText: String, handler: @escaping (_ success: Bool) -> Void) {
        let newActionPlan: InsightAddExtraActionPlanRequest = .init(contents: [newActionPlanText])
        InsightsDetailService.postSingleNewActionPlan(seedId: seedId, newActionPlan: newActionPlan)
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                self.getActionPlans()
                handler(true)
            }, onError: { error in
                print(error)
                handler(false)
            })
            .disposed(by: disposeBag)
    }
    
    
    func editActionPlan(actionPlanId: Int, editedActionPlanText: String, handler: @escaping (Bool) -> Void) {
        let newActionPlan: InsightActionPlanPatchRequest = .init(content: editedActionPlanText)
        InsightsDetailService.editActionPlan(actionPlanId: actionPlanId, editedActionPlan: newActionPlan)
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                self.getActionPlans()
                handler(true)
            }, onError: { error in
                print(error)
                handler(false)
            })
            .disposed(by: disposeBag)
    }
    
    func deleteActionPlan(actionPlanId: Int) {
        InsightsDetailService.deleteActionPlan(actionPlanId: actionPlanId)
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                self.getActionPlans()
                self.toastStatus.accept(.deleteActionPlan(success: true))
            }, onError: { error in
                print(error)
                self.toastStatus.accept(.deleteActionPlan(success: false))
            })
            .disposed(by: disposeBag)
    }
    

    func hideMemoView(_ hasActionPlans: Bool) {
        shouldHideMemoView.onNext(hasActionPlans)
    }
    
    func resetNetworkStatus() {
        networkStatus.accept(.normal)
    }
}

extension InsightsDetailViewModel {
    
    private func getSeedDetail() {
        InsightsDetailService.getSeedDetail(seedId: seedId)
            .subscribe(onNext: { [weak self] seedDetail in
                guard let self else { return }
                self.seedDetail.onNext(seedDetail)
            }, onError: { error in
                print(error)
                self.networkStatus.accept(.error(of: error))
            })
            .disposed(by: disposeBag)
    }
    
    private func getActionPlans() {
        InsightsDetailService.getAllActionPlans(seedId: seedId)
            .subscribe(onNext: { [weak self] actionPlans in
                guard let self else { return }
                self.actionPlans.accept(actionPlans)
            }, onError: { error in
                print(error)
                self.networkStatus.accept(.error(of: error))
            })
            .disposed(by: disposeBag)
    }
}
