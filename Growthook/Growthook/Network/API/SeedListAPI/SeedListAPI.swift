//
//  SeedListAPI.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

import Moya
import RxMoya
import RxSwift

final class SeedListAPI {
    static let shared: SeedListAPI = SeedListAPI()
    
    private let seedListProvider = MoyaProvider<SeedListTarget>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    public private(set) var seedListData: GeneralResponse<[SeedListResponseDto]>?
    public private(set) var caveSeedListData: GeneralResponse<[SeedListResponseDto]>?
    public private(set) var seedAlarmData: GeneralResponse<SeedAlarmResponseDto>?
    public private(set) var seedMoveData: GeneralResponse<SeedMoveRequestDto>?
    public private(set) var patchSeedData: GeneralResponse<PatchSeedRequestDto>?
    
    // MARK: - GET
    /// 인사이트 전체 조회
    func getSeedList(memberId: Int,
                     completion: @escaping (GeneralResponse<[SeedListResponseDto]>?) -> Void) {
        seedListProvider.request(.getSeedList(memberId: memberId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.seedListData = try response.map(GeneralResponse<[SeedListResponseDto]>?.self)
                    guard let seedListData = self.seedListData else { return }
                    completion(seedListData)
                    dump(seedListData)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    /// 동굴 별 인사이트 조회
    func getCaveSeedList(caveId: Int,
                         completion: @escaping (GeneralResponse<[SeedListResponseDto]>?) -> Void) {
        seedListProvider.request(.getSeedListByCave(caveId: caveId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.caveSeedListData = try response.map(GeneralResponse<[SeedListResponseDto]>?.self)
                    guard let caveSeedListData = self.caveSeedListData else { return }
                    completion(caveSeedListData)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    /// 인사이트 알림 조회
    func getSeedAlarm(memberId: Int,
                         completion: @escaping (GeneralResponse<SeedAlarmResponseDto>?) -> Void) {
        seedListProvider.request(.getSeedAlarm(memberId: memberId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.seedAlarmData = try response.map(GeneralResponse<SeedAlarmResponseDto>?.self)
                    guard let seedAlarmData = self.seedAlarmData else { return }
                    completion(seedAlarmData)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    // MARK: - POST
    /// 인사이트 동굴 이동
    func postSeedMove(seedId: Int,
                      completion: @escaping (GeneralResponse<SeedMoveRequestDto>?) -> Void) {
        seedListProvider.request(.postSeedMove(seedId: seedId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.seedMoveData = try response.map(GeneralResponse<SeedMoveRequestDto>?.self)
                    guard let seedMoveData = self.seedMoveData else { return }
                    completion(seedMoveData)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    // MARK: - DELETE
    /// 인사이트 삭제
    func deleteSeed(seedId: Int,
                    completion: @escaping (GeneralResponse<VoidType>?) -> Void) {
        seedListProvider.request(.deleteSeed(seedId: seedId)) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try response.map(GeneralResponse<VoidType>?.self)
                    print("😰😰😰😰😰😰😰")
                    completion(data)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    // MARK: - PATCH
    /// 씨앗 내용 수정
    func patchSeedDetail(seedId: Int,
                         completion: @escaping (GeneralResponse<PatchSeedRequestDto>?) -> Void) {
        seedListProvider.request(.patchSeed(seedId: seedId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.patchSeedData = try response.map(GeneralResponse<PatchSeedRequestDto>?.self)
                    guard let patchSeedData = self.patchSeedData else { return }
                    completion(patchSeedData)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    /// 씨앗 잠금 해제
    func patchSeedUnlock(seedId: Int,
                         completion: @escaping (GeneralResponse<VoidType>?) -> Void) {
        seedListProvider.request(.patchUnlockSeed(seedId: seedId)) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try response.map(GeneralResponse<VoidType>?.self)
                    completion(data)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    /// 씨앗 스크랩
    func patchSeedScrap(seedId: Int,
                        completion: @escaping (GeneralResponse<VoidType>?) -> Void) {
        seedListProvider.request(.patchSeedScrap(seedId: seedId)) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try response.map(GeneralResponse<VoidType>?.self)
                    completion(data)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
}
