//
//  SeedService.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum SeedListTarget {
    case getSeedList(memberId: Int)
    case getSeedListByCave(caveId: Int)
    case getSeedAlarm(memberId: Int)
    case deleteSeed(seedId: Int)
    case patchSeed(seedId: Int)
    case patchUnlockSeed(seedId: Int)
    case postSeedMove(seedId: Int)
    case patchSeedScrap(seedId: Int)
}

extension SeedListTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .getSeedList(memberId: let memberId):
            let path = URLConstant.seedListGet
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return path
        case .getSeedListByCave(caveId: let caveId):
            let path = URLConstant.seedListByCaveGet
                .replacingOccurrences(of: "{caveId}", with: String(caveId))
            return path
        case .getSeedAlarm(memberId: let memberId):
            let path = URLConstant.seedAlarm
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return path
        case .deleteSeed(seedId: let seedId):
            let path = URLConstant.seed
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return path
        case .patchSeed(seedId: let seedId):
            let path = URLConstant.seed
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return path
        case .patchUnlockSeed(seedId: let seedId):
            let path = URLConstant.unLockSeed
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return path
        case .postSeedMove(seedId: let seedId):
            let path = URLConstant.seedMove
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return path
        case .patchSeedScrap(seedId: let seedId):
            let path = URLConstant.toggleSeedScrapStatus
                .replacingOccurrences(of: "{seedId}", with: String(seedId))
            return path
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSeedList, .getSeedListByCave, .getSeedAlarm:
            return .get
        case .postSeedMove:
            return .post
        case .deleteSeed:
            return .delete
        case .patchSeed, .patchSeedScrap, .patchUnlockSeed:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return APIConstants.headerWithOutToken
    }
}

struct SeedListService: Networkable {
    typealias Target = SeedListTarget
    
    static private let provider = makeProvider()
    
    static func getAllSeedList(memberId: Int) -> Observable<[SeedListResponseDto]> {
        return provider.rx.request(.getSeedList(memberId: memberId))
            .asObservable()
            .mapError()
            .decode(decodeType: [SeedListResponseDto].self)
    }
}

