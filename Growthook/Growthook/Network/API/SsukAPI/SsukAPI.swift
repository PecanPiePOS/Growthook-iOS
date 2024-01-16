//
//  SsukAPI.swift
//  Growthook
//
//  Created by KJ on 1/12/24.
//

import Moya

final class SsukAPI {
    static let shared: SsukAPI = SsukAPI()
    
    private let ssukProvider = MoyaProvider<SsukTarget>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    public private(set) var ssukData: GeneralResponse<SsukResponseDto>?
    public private(set) var usedSsukData: GeneralResponse<SsukResponseDto>?
    
    // MARK: - GET
    /// 수확한 쑥 조회
    func getGatheredSsuk(memberId: Int,
                         completion: @escaping(GeneralResponse<SsukResponseDto>?) -> Void) {
        ssukProvider.request(.getSsuk(memberId: memberId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.ssukData = try response.map(GeneralResponse<SsukResponseDto>?.self)
                    guard let ssukData = self.ssukData else { return }
                    completion(ssukData)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    /// 사용한 쑥 조회
    func getUsedSsuk(memberId: Int,
                     completion: @escaping(GeneralResponse<SsukResponseDto>?) -> Void) {
        ssukProvider.request(.getUsedSsuk(memberId: memberId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.usedSsukData = try response.map(GeneralResponse<SsukResponseDto>?.self)
                    guard let usedSsukData = self.usedSsukData else { return }
                    completion(usedSsukData)
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
