//
//  HomeViewModel.swift
//  Growthook
//
//  Created by KJ on 11/10/23.
//

import UIKit

import RxSwift
import RxCocoa
import Moya

protocol HomeViewModelInputs {
    func handleLongPress(at indexPath: IndexPath)
    func dismissInsightTap(at indexPath: IndexPath)
    func reloadInsight()
    func reloadCave()
    func insightCellTap(at indexPath: IndexPath)
    func giveUpButtonTap()
    func caveListCellTap(at indexPath: IndexPath)
    func selectButtonTap()
    func caveDetail(caveId: Int)
    func alarmButtonTap(memberId: Int)
    func moveMenuTap()
    func removeMenuTap()
    func keepButtonTap()
    func removeButtonTap()
    func insightScrap(seedId: Int)
    func insightCaveScrap(seedId: Int, caveId: Int)
    func unLockSeedAlert(seedId: Int)
    func unLockSeedAlertInCave(seedId: Int)
    func caveInsightList(caveId: Int)
    func caveListMove(caveId: Int)
    func removeCaveButtonTap(caveId: Int)
    func onlyScrapInsight()
    func caveOnlyScrapInsight(caveId: Int)
    func changeCaveButtonTap()
}

protocol HomeViewModelOutputs {
    var caveProfile: BehaviorRelay<[CaveListResponseDto]> { get }
    var insightList: BehaviorRelay<[SeedListResponseDto]> { get }
    var insightLongTap: PublishSubject<IndexPath> { get }
    var insightBackground: PublishSubject<IndexPath> { get }
    var pushToInsightDetail: PublishSubject<IndexPath> { get }
    var selectedCellIndex: BehaviorRelay<IndexPath?> { get }
    var moveToCave: PublishSubject<Void> { get }
    var insightAlarm: BehaviorRelay<Int> { get }
    var presentToCaveList: PublishSubject<Void> { get }
    var removeInsightAlertView: PublishSubject<Void> { get }
    var dismissToHome: PublishSubject<Void> { get }
    var removeInsight: PublishSubject<Void> { get }
    var reloadCaves: PublishSubject<Void>  { get }
    var reloadInsights: PublishSubject<Void> { get }
    var insightScrapToggle: PublishSubject<Void> { get }
    var unLockSeed: PublishSubject<Void> { get }
    var unLockSeedInCave: PublishSubject<Void> { get }
    var caveDetail: BehaviorRelay<CaveDetailResponseDto> { get }
    var caveInsightList: BehaviorRelay<[SeedListResponseDto]> { get }
    var removeCave: PublishSubject<Void> { get }
    var insightAllCount: BehaviorRelay<Int> { get }
    var caveInsightAllCount: BehaviorRelay<Int> { get }
    var ssukCount: BehaviorRelay<SsukResponseDto> { get }
    var pushToChangeCave: PublishSubject<Void> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

final class HomeViewModel: HomeViewModelInputs, HomeViewModelOutputs, HomeViewModelType {
    
    var caveProfile: BehaviorRelay<[CaveListResponseDto]> = BehaviorRelay(value: [])
    var insightList: BehaviorRelay<[SeedListResponseDto]> = BehaviorRelay<[SeedListResponseDto]>(value: [])
    var insightLongTap: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var insightBackground: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var reloadCaves: PublishSubject<Void> = PublishSubject<Void>()
    var reloadInsights: PublishSubject<Void> = PublishSubject<Void>()
    var pushToInsightDetail: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var dismissToHomeVC: PublishSubject<Void> = PublishSubject<Void>()
    var moveToCave: PublishSubject<Void> = PublishSubject<Void>()
    var insightAlarm: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var insightScrapToggle: PublishSubject<Void> = PublishSubject<Void>()
    var unLockSeed: PublishSubject<Void> = PublishSubject<Void>()
    var unLockSeedInCave: PublishSubject<Void> = PublishSubject<Void>()
    var caveDetail: BehaviorRelay<CaveDetailResponseDto> = BehaviorRelay<CaveDetailResponseDto>(value: CaveDetailResponseDto.caveDetailInitValue())
    var caveInsightList: BehaviorRelay<[SeedListResponseDto]> = BehaviorRelay<[SeedListResponseDto]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    // state
    private var selectedSeedId: Int?
    var insightModel: [SeedListResponseDto] = []
    private var caveId: Int?
    var memberId: Int = UserDefaults.standard.integer(forKey: I18N.Auth.memberId)
    
    // 인사이트 선택
    var presentToCaveList: PublishSubject<Void> = PublishSubject<Void>()
    var removeInsightAlertView: PublishSubject<Void> = PublishSubject<Void>()
    
    // 인사이트 이동
    var selectedCellIndex: BehaviorRelay<IndexPath?> = BehaviorRelay<IndexPath?>(value: nil)
    
    // 인사이트 삭제
    var dismissToHome: PublishSubject<Void> = PublishSubject<Void>()
    var removeInsight: PublishSubject<Void> = PublishSubject<Void>()
    
    // 동굴 삭제
    var removeCave: PublishSubject<Void> = PublishSubject<Void>()
    
    // 인사이트 개수
    var insightAllCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    var caveInsightAllCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    
    // 현재 쑥 개수
    var ssukCount: BehaviorRelay<SsukResponseDto> = BehaviorRelay<SsukResponseDto>(value: SsukResponseDto.ssukDummy())
    
    // 동굴 수정 뷰로 이동
    var pushToChangeCave: PublishSubject<Void> = PublishSubject<Void>()
    
    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }
    
    init() {
        self.getSeedList(memberId: memberId)
        self.getCaveList(memberId: memberId)
        self.getSsukCount(memberId: memberId)
    }
    
    func handleLongPress(at indexPath: IndexPath) {
        let items = insightList.value
        let selectedItem = items[indexPath.item]
        print("\(selectedItem.seedId) / 제목 :  \(selectedItem.insight)")
        self.selectedSeedId = selectedItem.seedId
        self.insightLongTap.onNext(indexPath)
    }
    
    func dismissInsightTap(at indexPath: IndexPath) {
        self.insightBackground.onNext(indexPath)
    }
    
    func reloadCave() {
        self.getCaveList(memberId: memberId)
    }
    
    func reloadInsight() {
        self.getSeedList(memberId: memberId)
    }
    
    func caveDetail(caveId: Int) {
        self.getCaveDetail(memberId: memberId, caveId: caveId)
    }
    
    func caveInsightList(caveId: Int) {
        self.getCaveSeedList(caveId: caveId)
        self.caveId = caveId
    }
    
    func insightCellTap(at indexPath: IndexPath) {
        self.pushToInsightDetail.onNext(indexPath)
    }
    
    func giveUpButtonTap() {
        self.dismissToHomeVC.onNext(())
    }
    
    func caveListCellTap(at indexPath: IndexPath) {
        selectedCellIndex.accept(indexPath)
    }
    
    func caveListMove(caveId: Int) {
        self.postSeedMove(caveId: caveId)
        return moveToCave.onNext(())
    }
    
    func alarmButtonTap(memberId: Int) {
        SeedListAPI.shared.getSeedAlarm(memberId: memberId) { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            self?.insightAlarm.accept(data.seedCount)
        }
    }
    
    func insightScrap(seedId: Int) {
        let seedId = seedId
        SeedListAPI.shared.patchSeedScrap(seedId: seedId) { [weak self] response in
            guard self != nil else { return }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.getSeedList(memberId: self.memberId)
        }
    }
    
    func insightCaveScrap(seedId: Int, caveId: Int) {
        let seedId = seedId
        let caveId = caveId
        SeedListAPI.shared.patchSeedScrap(seedId: seedId) { [weak self] response in
            guard self != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.getCaveSeedList(caveId: caveId)
            }
        }
    }
    
    func unLockSeedAlert(seedId: Int) {
        let seedId = seedId
        SeedListAPI.shared.patchSeedUnlock(seedId: seedId) { [weak self] response in
            guard self != nil else { return }
            self?.unLockSeed.onNext(())
        }
    }
    
    func unLockSeedAlertInCave(seedId: Int) {
        let seedId = seedId
        SeedListAPI.shared.patchSeedUnlock(seedId: seedId) { [weak self] response in
            guard self != nil else { return }
            self?.unLockSeedInCave.onNext(())
        }
    }
    
    // 인사이트 선택
    func moveMenuTap() {
        presentToCaveList.onNext(())
    }
    
    func removeMenuTap() {
        removeInsightAlertView.onNext(())
    }
    
    // 인사이트 이동
    func selectButtonTap() {
        
    }
    
    // 인사이트 삭제
    func keepButtonTap() {
        self.dismissToHome.onNext(())
    }
    
    // 스크랩만 보기 버튼 탭
    func onlyScrapInsight() {
        getSeedList(memberId: memberId)
    }
    
    func caveOnlyScrapInsight(caveId: Int) {
        getCaveSeedList(caveId: caveId)
    }
    
    func removeButtonTap() {
        guard let seedId = selectedSeedId else { return }
        SeedListAPI.shared.deleteSeed(seedId: seedId) { [weak self] response in
            guard self != nil else { return }
            guard let memberId = self?.memberId else { return }
            self?.removeInsight.onNext(())
            self?.getSeedList(memberId: memberId)
            if let caveId = self?.caveId {
                self?.getCaveSeedList(caveId: caveId)
            }
        }
    }
    
    func removeCaveButtonTap(caveId: Int) {
        let caveId = caveId
        CaveAPI.shared.deleteCave(caveId: caveId) { [weak self] response in
            guard self != nil else { return }
            self?.removeCave.onNext(())
        }
    }
    
    func changeCaveButtonTap() {
        self.pushToChangeCave.onNext(())
    }
}

extension HomeViewModel {
    
    func getSeedList(memberId: Int) {
        SeedListService.getAllSeedList(memberId: memberId)
            .subscribe(onNext: { [weak self] list in
                guard let self else { return }
                self.insightList.accept(list)
                self.insightModel = list
                self.insightAllCount.accept(list.count)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func getCaveList(memberId: Int) {
        CaveAPI.shared.getCaveAll(memberId: memberId) { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            self?.caveProfile.accept(data)
        }
    }
    
    func getCaveDetail(memberId: Int, caveId: Int) {
        let caveId = caveId
        CaveAPI.shared.getCaveDetail(memberId: memberId, caveId: caveId) { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            self?.caveDetail.accept(data)
        }
    }
    
    func getCaveSeedList(caveId: Int) {
        let caveId = caveId
        SeedListAPI.shared.getCaveSeedList(caveId: caveId) { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            self?.caveInsightList.accept(data)
            self?.caveInsightAllCount.accept(data.count)
        }
    }
    
    func postSeedMove(caveId: Int) {
        let caveId = caveId
        let model: SeedMoveRequestDto = SeedMoveRequestDto(caveId: caveId)
        guard let seedId = selectedSeedId else { return }
        SeedListAPI.shared.postSeedMove(seedId: seedId, param: model) { [weak self] response in
            guard self != nil else { return }
            guard let memberId = self?.memberId else { return }
            if let caveId = self?.caveId {
                self?.getCaveSeedList(caveId: caveId)
                self?.getSeedList(memberId: memberId)
            }
        }
    }
    
    func getSsukCount(memberId: Int) {
        SsukAPI.shared.getGatheredSsuk(memberId: memberId) { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            self?.ssukCount.accept(data)
        }
    }
    
    private func getNewToken() {
        AuthAPI.shared.getRefreshToken() { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            if let accessTokenData = data.accessToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
            }

            if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
            }
            APIConstants.jwtToken = data.accessToken
            APIConstants.refreshToken = data.refreshToken
        }
    }
}
