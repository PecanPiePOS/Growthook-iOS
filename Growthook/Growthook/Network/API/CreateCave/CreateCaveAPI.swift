//
//  CreateCaveAPI.swift
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
            let newPath = URLConstant.seedPost
                .replacingOccurrences(of: "{memberId}", with: String(memberId))
            return newPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postcave:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postcave(_, let parameter):
            let parameters = try! parameter.asParameter()
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
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
