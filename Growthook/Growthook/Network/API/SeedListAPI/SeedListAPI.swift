//
//  SeedListAPI.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Foundation

import Moya

final class SeedListAPI {
    static let shared: SeedListAPI = SeedListAPI()
    
    private let seedListProvider = MoyaProvider<SeedListService>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    public private(set) var seedListData: GeneralResponse<[SeedListResponseDto]>?
    
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
    
    
    /// 인사이트 알림 조회
    
}
