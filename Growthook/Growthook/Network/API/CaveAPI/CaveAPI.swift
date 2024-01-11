//
//  CaveAPI.swift
//  Growthook
//
//  Created by KJ on 1/11/24.
//

import Moya

final class CaveAPI {
    static let shared: CaveAPI = CaveAPI()
    
    private let caveProvider = MoyaProvider<CaveTarget>(plugins: [NetworkLoggerPlugin()])
    
    private init() {}
    
    public private(set) var caveAllData: GeneralResponse<[CaveListResponseDto]>?
    public private(set) var caveDetailData: GeneralResponse<CaveDetailResponseDto>?
    public private(set) var cavePatchData: GeneralResponse<CavePatchRequestDto>?
    
    // MARK: - GET
    /// 동굴 리스트 조회
    func getCaveAll(memberId: Int,
                    completion: @escaping(GeneralResponse<[CaveListResponseDto]>?) -> Void) {
        caveProvider.request(.getCaveAll(memberId: memberId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.caveAllData = try response.map(GeneralResponse<[CaveListResponseDto]>?.self)
                    guard let caveAllData = self.caveAllData else { return }
                    completion(caveAllData)
                } catch let err {
                    print(err.localizedDescription, 500)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    /// 동굴 상세 조회
    func getCaveDetail(memberId: Int, caveId: Int,
                    completion: @escaping(GeneralResponse<CaveDetailResponseDto>?) -> Void) {
        caveProvider.request(.getCaveDetail(memberId: memberId, caveId: caveId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.caveDetailData = try response.map(GeneralResponse<CaveDetailResponseDto>?.self)
                    guard let caveDetailData = self.caveDetailData else { return }
                    completion(caveDetailData)
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
    /// 동굴 삭제
    func deleteCave(caveId: Int,
                    completion: @escaping (GeneralResponse<VoidType>?) -> Void) {
        caveProvider.request(.deleteCave(caveId: caveId)) { result in
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
    /// 동굴 내용 수정
    func patch(caveId: Int,
                    completion: @escaping (GeneralResponse<CavePatchRequestDto>?) -> Void) {
        caveProvider.request(.patchCave(caveId: caveId)) { result in
            switch result {
            case .success(let response):
                do {
                    self.cavePatchData = try response.map(GeneralResponse<CavePatchRequestDto>?.self)
                    guard let cavePatchData = self.cavePatchData else { return }
                    completion(cavePatchData)
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
