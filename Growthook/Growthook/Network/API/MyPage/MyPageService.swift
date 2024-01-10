//
//  MyPageService.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/10/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum MyPageTarget {
    case getUserProfile(memberId: Int)
    case getEarnedSsuk(memberId: Int)
    case getSpentSsuk(memberId: Int)
}

extension MyPageTarget: BaseTargetType {
    
    var headers: [String : String]? {
        APIConstants.headerWithAuthorization
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var path: String {
        switch self {
        case .getUserProfile(let memberId):
            let newPath = URLConstant.myPageUserInfo
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        case .getEarnedSsuk(let memberId):
            let newPath = URLConstant.myPageGetEarnedSsuk
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        case .getSpentSsuk(let memberId):
            let newPath = URLConstant.myPageGetSpentSsuk
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserProfile, .getEarnedSsuk, .getSpentSsuk:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getUserProfile, .getEarnedSsuk, .getSpentSsuk:
            return .requestPlain
        }
    }
}

struct MyPageService: Networkable {
    typealias Target = MyPageTarget
    private static let provider = makeProvider()
    
    static func getUserInfo(with memberId: Int) -> Observable<MyPageUserInfoResponse> {
        return provider.rx.request(.getUserProfile(memberId: memberId))
            .asObservable()
            .mapError()
            .decode(decodeType: MyPageUserInfoResponse.self)
    }
    
    static func getEarnedSsuck(with memberId: Int) -> Observable<MyPageEarnedSsukResponse> {
        return provider.rx.request(.getEarnedSsuk(memberId: memberId))
            .asObservable()
            .mapError()
            .decode(decodeType: MyPageEarnedSsukResponse.self)
    }
    
    static func getSpentSsuk(with memberId: Int) -> Observable<MyPageEarnedSsukResponse> {
        return provider.rx.request(.getSpentSsuk(memberId: memberId))
            .asObservable()
            .mapError()
            .decode(decodeType: MyPageEarnedSsukResponse.self)
    }
}
