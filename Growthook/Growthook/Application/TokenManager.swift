//
//  TokenManager.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/25/24.
//

import Foundation
import Security

import Moya

final class TokenManager {
    
    static let shared = TokenManager()
    private let authProvider = MoyaProvider<AuthTarget>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    func refreshNewToken() {
        AuthAPI.shared.getRefreshToken() { response in
            guard let data = response?.data else { return }
            print("New Token is now valid.")
            if let accessTokenData = data.accessToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.jwtToken, data: accessTokenData)
            }

            if let refreshTokenData = data.refreshToken.data(using: .utf8) {
                KeychainHelper.save(key: I18N.Auth.refreshToken, data: refreshTokenData)
            }
        }
    }
}
