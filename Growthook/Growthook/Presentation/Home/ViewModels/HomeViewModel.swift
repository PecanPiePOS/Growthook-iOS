//
//  HomeViewModel.swift
//  Growthook
//
//  Created by KJ on 11/10/23.
//

import UIKit

import RxSwift
import RxCocoa

protocol HomeViewModelInputs {
    func handleLongPress(at indexPath: IndexPath)
    func dismissInsightTap(at indexPath: IndexPath)
    func reloadInsight()
    func insightCellTap(at indexPath: IndexPath)
    func giveUpButtonTap()
    func caveListCellTap(at indexPath: IndexPath)
    func selectButtonTap()
    func caveCellTap(at indexPath: IndexPath)
}

protocol HomeViewModelOutputs {
    var caveProfile: BehaviorRelay<[CaveProfile]> { get }
    var insightList: BehaviorRelay<[GetSeedListResponseDto]> { get }
    var insightLongTap: PublishSubject<IndexPath> { get }
    var insightBackground: PublishSubject<IndexPath> { get }
    var pushToInsightDetail: PublishSubject<IndexPath> { get }
    var selectedCellIndex: BehaviorRelay<IndexPath?> { get }
    var moveToCave: PublishSubject<Void> { get }
    var pushToCaveDetail: PublishSubject<IndexPath> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

final class HomeViewModel: HomeViewModelInputs, HomeViewModelOutputs, HomeViewModelType {
    
    var caveProfile: BehaviorRelay<[CaveProfile]> = BehaviorRelay(value: [])
    var insightList: BehaviorRelay<[GetSeedListResponseDto]> = BehaviorRelay<[GetSeedListResponseDto]>(value: [])
    var insightLongTap: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var insightBackground: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    let reloadInsightSubject: PublishSubject<Void> = PublishSubject<Void>()
    var pushToInsightDetail: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    var dismissToHomeVC: PublishSubject<Void> = PublishSubject<Void>()
    var selectedCellIndex: BehaviorRelay<IndexPath?> = BehaviorRelay<IndexPath?>(value: nil)
    var moveToCave: PublishSubject<Void> = PublishSubject<Void>()
    var pushToCaveDetail: PublishSubject<IndexPath> = PublishSubject<IndexPath>()
    
    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }
    
    init() {
        self.requestGetSeedList(memberId: 3)
//        self.insightList.accept(InsightList.insightDummy())
        self.caveProfile.accept(CaveProfile.caveprofileDummyData())
    }
    
    func handleLongPress(at indexPath: IndexPath) {
        let items = insightList.value
        let selectedItem = items[indexPath.item]
        print("\(indexPath.row) / 제목 :  \(selectedItem.insight)")
        self.insightLongTap.onNext(indexPath)
    }
    
    func dismissInsightTap(at indexPath: IndexPath) {
        self.insightBackground.onNext(indexPath)
    }
    
    func reloadInsight() {
        self.reloadInsightSubject.onNext(())
    }
    
    func caveCellTap(at indexPath: IndexPath) {
        self.pushToCaveDetail.onNext(indexPath)
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
    
    func selectButtonTap() {
        return moveToCave.onNext(())
    }
}

extension HomeViewModel {
    
    func requestGetSeedList(memberId: Int) {
        SeedListAPI.shared.getSeedList(memberId: memberId) { [weak self] response in
            guard self != nil else { return }
            guard let data = response?.data else { return }
            self?.insightList.accept(data)
        }
    }
}
