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
            if success != false { return "할 일을 계획했어요!" } else { return "실패했어요" }
        }
    }
}

enum PostSuccessState {
    case normal
    case error(of: Error)
    case done
}

enum InsightDetailNetworkState {
    case normal
    case error(of: Error)
}

protocol InsightsDetailViewModelInput {
    func navigationBarMenuDidTap()
    func relocateSeed(to newCaveId: Int)
    func editSeed(editedSeed :InsightEditRequest)
    func deleteSeedDidTap(handler: @escaping (Bool) -> Void)
    func moveSeedToOtherCave(of selectedCave: InsightCaveModel)
    func getAllCaves()
    func reloadActionPlan()
    func reloadSeedData()
    func completeActionPlan(actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void)
    func postReviewToComplete(review: String, actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void)
    func insightScrap(handler: @escaping (_ success:Bool) -> Void)
    func actionPlanScrap(actionPlanId: Int, handler: @escaping (_ success:Bool) -> Void)
    
    func readMoreDidTap()
    func actionPlanMenuDidTap()
    func completeActionPlan(withReviewOf review: String?, actionPlanIdOf actionPlanId: Int, handler: @escaping (Bool) -> Void)
    func addSingleNewAction(newActionPlanText: String, handler: @escaping (Bool) -> Void)
    func editActionPlan(actionPlanId: Int, editedActionPlanText: String, handler: @escaping (_ success: Bool) -> Void)
    func deleteActionPlan(actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void)
    
    func hideMemoView(_ hasActionPlans: Bool)
    func resetToastStatus()
    func resetNetworkStatus()
    func fetchSeedModel() -> SeedEditModel
}

protocol InsightsDetailViewModelOutput {
    var shouldHideMemoView: PublishSubject<Bool> { get }
    var toastStatus: BehaviorRelay<InsightsDetailToastType> { get }
    var networkStatus: BehaviorRelay<InsightDetailNetworkState> { get }
    
    var seedDetail: PublishSubject<SeedDetailResponsse> { get }
    var caveData: BehaviorRelay<[InsightCaveModel]> { get }
    var actionPlans: BehaviorRelay<[InsightActionPlanResponse]> { get }
    var actionPlanPatchStatus: BehaviorRelay<PostSuccessState> { get }
    var scrapedStatus: BehaviorRelay<Bool> { get }
}

protocol InsightsDetailViewModelType {
    var inputs: InsightsDetailViewModelInput { get }
    var outputs: InsightsDetailViewModelOutput { get }
}

final class InsightsDetailViewModel: InsightsDetailViewModelInput, InsightsDetailViewModelOutput, InsightsDetailViewModelType {
    
    var actionPlanPatchStatus =  BehaviorRelay<PostSuccessState>(value: .normal)
    var networkStatus = BehaviorRelay<InsightDetailNetworkState>(value: .normal)
    var toastStatus = BehaviorRelay<InsightsDetailToastType>(value: .none)
    var shouldHideMemoView = PublishSubject<Bool>()
    var seedDetail = PublishSubject<SeedDetailResponsse>()
    var caveData = BehaviorRelay<[InsightCaveModel]>(value: [])
    var actionPlans = BehaviorRelay<[InsightActionPlanResponse]>(value: [])
    var scrapedStatus = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    private let seedId: Int
    private var seedEditData: SeedEditModel?
    private let memberId = UserDefaults.standard.integer(forKey: I18N.Auth.memberId)

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
    
    func editSeed(editedSeed: InsightEditRequest) {
        InsightsService.editInsight(seedId: seedId, of: editedSeed)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.toastStatus.accept(.editSeedToast(success: true))
            }, onError: { error in
                print(error)
                self.toastStatus.accept(.editSeedToast(success: false))
            })
            .disposed(by: disposeBag)
    }
    
    /// 실패했을 때만, 해당 씨앗 조회 화면에서 toast 를 띄웁니다.
    /// 성공시에 toast 를 띄우는 것은 다른 화면입니다.
    func deleteSeedDidTap(handler: @escaping (Bool) -> Void) {
        InsightsService.deleteInsight(seedId: seedId) { [weak self] success in
            guard let self else { return }
            switch success {
            case true:
                handler(true)
            case false:
                handler(false)
                self.toastStatus.accept(.deleteActionPlan(success: false))
                self.resetToastStatus()
            }
        }
    }
    
    func moveSeedToOtherCave(of selectedCave: InsightCaveModel) {
        InsightsDetailService.moveSeed(withSeedOf: seedId, to: selectedCave.caveId)
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
    
    func completeActionPlan(actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        InsightsDetailService.completeActionPlan(actionPlanId: actionPlanId) { [weak self] success in
            guard let self else { return }
            switch success {
            case true:
                handler(true)
                self.getActionPlans()
            case false:
                handler(false)
            }
        }
    }
    
    func postReviewToComplete(review: String, actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        InsightsDetailService.postReview(content: review, actionPlanId: actionPlanId) { [weak self] success in
            switch success {
            case true:
                handler(true)
            case false:
                handler(false)
            }
        }
    }
    
    func addSingleNewAction(newActionPlanText: String, handler: @escaping (Bool) -> Void) {
        let newActionPlan: InsightAddExtraActionPlanRequest = .init(contents: [newActionPlanText])
        InsightsDetailService.postSingleNewActionPlan(seedId: seedId, newActionPlan: newActionPlan) { [weak self] success in
            guard let self else { return }
            switch success {
            case true:
                handler(true)
                self.toastStatus.accept(.createActionPlan(success: true))
                self.resetToastStatus()
                self.shouldHideMemoView.onNext(true)
            case false:
                handler(false)
                self.toastStatus.accept(.createActionPlan(success: false))
                self.resetToastStatus()
            }
        }
    }
    
    func editActionPlan(actionPlanId: Int, editedActionPlanText: String, handler: @escaping (_ success: Bool) -> Void) {
        let newActionPlan: InsightActionPlanPatchRequest = .init(content: editedActionPlanText)
        InsightsDetailService.editActionPlan(actionPlanId: actionPlanId, editedActionPlan: newActionPlan) { [weak self] success in
            guard let self else { return }
            switch success {
            case true:
                handler(true)
                self.toastStatus.accept(.editActionPlan(success: true))
                self.resetToastStatus()
            case false:
                handler(false)
                self.toastStatus.accept(.editActionPlan(success: false))
                self.resetToastStatus()
            }
        }
    }
    
    func deleteActionPlan(actionPlanId: Int, handler: @escaping (_ success: Bool) -> Void) {
        
        InsightsDetailService.deleteActionPlan(actionPlanId: actionPlanId) { [weak self] success in
            guard let self else { return }
            switch success {
            case true:
                handler(true)
                self.toastStatus.accept(.deleteActionPlan(success: true))
                self.resetToastStatus()
                self.reloadActionPlan()
                if self.actionPlans.value.isEmpty {
                    self.shouldHideMemoView.onNext(false)
                } else {
                    self.shouldHideMemoView.onNext(true)
                }
            case false:
                handler(false)
                self.toastStatus.accept(.deleteSeedToast(success: false))
                self.resetToastStatus()
            }
        }
    }
    
    func insightScrap(handler: @escaping (_ success:Bool) -> Void) {
        InsightsDetailService.scrapSeed(seedId: seedId) { [weak self] success in
            guard let self else { return }
            switch success {
            case true:
                let isScraped = self.scrapedStatus.value
                self.scrapedStatus.accept(!isScraped)
                self.toastStatus.accept(.scrapToast(success: true))
                handler(true)
                self.resetToastStatus()
            case false:
                self.toastStatus.accept(.scrapToast(success: false))
                handler(false)
                self.resetToastStatus()
            }
        }
    }
    
    func actionPlanScrap(actionPlanId: Int, handler: @escaping (_ success:Bool) -> Void) {
        InsightsDetailService.scrapActionPlan(actionPlanId: actionPlanId)  { [weak self] success in
            guard let self else { return }
            switch success {
            case true:
                self.toastStatus.accept(.scrapToast(success: true))
                handler(true)
                self.resetToastStatus()
            case false:
                self.toastStatus.accept(.scrapToast(success: false))
                handler(false)
                self.resetToastStatus()
            }
        }
    }

    func hideMemoView(_ hasActionPlans: Bool) {
        shouldHideMemoView.onNext(hasActionPlans)
    }
    
    func resetNetworkStatus() {
        networkStatus.accept(.normal)
    }
    
    func getAllCaves() {
        InsightsDetailService.getAllCaves(memberId: memberId)
            .subscribe(onNext: { [weak self] caves in
                guard let self else { return }
                let caveModel: [InsightCaveModel] = caves.map { .init(caveId: $0.caveId, caveTitle: $0.caveName) }
                self.caveData.accept(caveModel)
            }, onError: { error in
                print(error)
                self.caveData.accept([])
            })
            .disposed(by: disposeBag)
    }
    
    func fetchSeedModel() -> SeedEditModel {
        guard let seedEditData else {
            return SeedEditModel(caveName: "", insight: "", source: "", memo: "", url: "")
        }
        return seedEditData
    }
    
    func fetchSeedId() -> Int {
        return seedId
    }
    
    func reloadActionPlan() {
        getActionPlans()
    }
    
    func reloadSeedData() {
        getSeedDetail()
    }
}

extension InsightsDetailViewModel {
    
    private func getSeedDetail() {
        InsightsDetailService.getSeedDetail(seedId: seedId)
            .subscribe(onNext: { [weak self] seedDetail in
                guard let self else { return }
                self.seedDetail.onNext(seedDetail)
                self.scrapedStatus.accept(seedDetail.isScraped)
                self.seedEditData = .init(caveName: seedDetail.caveName, insight: seedDetail.insight, source: seedDetail.source, memo: seedDetail.memo, url: seedDetail.url)
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
                if actionPlans.isEmpty != false {
                    shouldHideMemoView.onNext(false)
                } else {
                    shouldHideMemoView.onNext(true)
                }
            }, onError: { error in
                print(error)
                self.networkStatus.accept(.error(of: error))
            })
            .disposed(by: disposeBag)
    }
}
