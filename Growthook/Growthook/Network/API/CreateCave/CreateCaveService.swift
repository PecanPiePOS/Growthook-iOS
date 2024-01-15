//
//  CreateCaveService.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/8/24.
//

import Foundation

import Moya
import RxCocoa
import RxMoya
import RxSwift

enum CreateCaveTarget {
    case postcave(memberId: Int, parameter: CreateCaveRequest)
    case getcavedetail(memberId: Int, caveId: Int)
}

extension CreateCaveTarget: BaseTargetType {
    
    var headers: [String : String]? {
        APIConstants.headerWithAuthorization
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var path: String {
        switch self {
        case .postcave(let memberId, _):
            let newPath = URLConstant.cavePost
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        case .getcavedetail(let memberId, let caveId):
            let newPath = URLConstant.caveDetailGet
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
                .replacingOccurrences(of: "{caveId}", with: String(caveId))
            return newPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postcave:
            return .post
        case .getcavedetail:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postcave(_, let parameter):
            let parameters = try! parameter.asParameter()
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getcavedetail(_, _):
            return .requestPlain
        }
    }
}

struct CreateCaveService: Networkable {
    typealias Target = CreateCaveTarget
    private static let provider = makeProvider()

    static func postcave(memberId: Int, cave: CreateCaveRequest) -> Observable<CreateCaveResponse> {
        return provider.rx.request(.postcave(memberId: memberId, parameter: cave))
            .asObservable()
            .mapError()
            .decode(decodeType: CreateCaveResponse.self)
    }
}

struct CreateCaveRequest: Codable {
    var name: String
    var introduction: String
    var isShared: Bool
}

struct CreateCaveResponse: Codable {
    var caveId: Int
}

struct CaveDetailResponse: Codable {
    var caveName: String
    var introduction: String
    var nickname: String
    var isShared: Bool
}

struct CaveDetailModel {
    var caveName: String
    var introduction: String
    var nickname: String
    var isShared: Bool
}
