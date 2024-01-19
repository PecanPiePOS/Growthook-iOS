//
//  AuthAPI.swift
//  Growthook
//
//  Created by KJ on 1/18/24.
//

import Moya
import Foundation

final class AuthAPI {
    static let shared: AuthAPI = AuthAPI()
    
    private let authProvider = MoyaProvider<AuthTarget>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    public private(set) var authData: GeneralResponse<LoginResponseDto>?
    public private(set) var refreshTokenData: GeneralResponse<RefreshTokenResponseDto>?
    
    // MARK: - POST
    /// 카카오 로그인
    func postKakaoLogin(param: LoginRequestDto, completion: @escaping (GeneralResponse<LoginResponseDto>?) -> Void) {
        authProvider.request(.login(param: param)) {
            result in
            switch result {
            case .success(let response):
                let status = response.statusCode
                    do {
                        self.authData = try response.map(GeneralResponse<LoginResponseDto>?.self)
                        guard let authData = self.authData else { return }
                        completion(authData)
                    } catch let err {
                        print(err.localizedDescription, 500)
                    }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    // MARK: - GET
    /// 토큰 재발급
    func getRefreshToken(completion: @escaping (GeneralResponse<RefreshTokenResponseDto>?) -> Void) {
        authProvider.request(.tokenRefresh) {
            result in
            switch result {
            case .success(let response):
                do {
                    self.refreshTokenData = try response.map(GeneralResponse<RefreshTokenResponseDto>?.self)
                    guard let refreshTokenData = self.refreshTokenData else { return }
                    completion(refreshTokenData)
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
