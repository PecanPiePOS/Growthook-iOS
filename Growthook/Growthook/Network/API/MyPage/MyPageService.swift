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
    
    /**
     유저의 이름과 메일 정보를 호출합니다.
     - parameter memberId: Int
     */
    static func getUserInfo(with memberId: Int) -> Observable<MyPageUserInfoResponse> {
        return provider.rx.request(.getUserProfile(memberId: memberId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: MyPageUserInfoResponse.self)
    }
    
    /**
     번 쑥 정보를 호출합니다.
     - parameter memberId: Int
     */
    static func getEarnedSsuck(with memberId: Int) -> Observable<MyPageEarnedSsukResponse> {
        return provider.rx.request(.getEarnedSsuk(memberId: memberId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: MyPageEarnedSsukResponse.self)
    }
    
    /**
     사용한 쑥 정보를 호출합니다.
     - parameter memberId: Int
     */
    static func getSpentSsuk(with memberId: Int) -> Observable<MyPageSpentSsukResponse> {
        return provider.rx.request(.getSpentSsuk(memberId: memberId))
            .asObservable()
            .mapError()
            .retryOnTokenExpired()
            .decode(decodeType: MyPageSpentSsukResponse.self)
    }
}
