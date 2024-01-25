//
//  TokenManager.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/25/24.
//

import Foundation
import Security

import Moya
import RxSwift
import RxMoya

final class TokenManager {
    
    static let shared = TokenManager()
    private let authProvider = MoyaProvider<AuthTarget>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    func refreshNewToken(retryHandler: @escaping (_ success: Bool) -> Void) {
        AuthAPI.shared.getRefreshToken { response in
            guard response != nil else {
                retryHandler(false)
                return
            }
            guard let data = response?.data else { return }
            APIConstants.jwtToken = data.accessToken
            APIConstants.refreshToken = data.refreshToken
            if let accessTokenData = data.accessToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
            }

            if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
            }
            retryHandler(true)
        }
    }
    
    func refreshNewToken() -> Observable<Void> {
        return authProvider.rx.request(.tokenRefresh)
            .asObservable()
            .decode(decodeType: RefreshTokenResponseDto.self)
            .do(onNext: { data in
                print("🔥")
                print("New Token is now valid.")
                APIConstants.jwtToken = data.accessToken
                APIConstants.refreshToken = data.refreshToken
                if let accessTokenData = data.accessToken.data(using: .utf8) {
                    KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
                }

                if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                    KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
                }
            })
            .map {_ in}
    }
}
