//
//  APIConstant.swift
//  Growthook
//
//  Created by KJ on 11/4/23.
//

import Foundation

enum NetworkHeaderKey: String {
    case deviceToken = "deviceToken"
    case accessToken = "accesstoken"
    case contentType = "Content-Type"
    case authorization = "Authorization"
}

enum APIConstants {
    
    static let accept: String = "Accept"
    static let auth: String = "x-auth-token"
    static let applicationJSON = "application/json"
    static var deviceToken: String = ""
    static var jwtToken: String = ""
    static var memberId: Int = 4
    static var accessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MDU2NTI4ODEsImV4cCI6MTcwNTkxMjA4MSwiaWQiOjd9.4U9IkvyFGXpJrdY4cj3IYLhpbTnqWwxtFhkDUyBVL7o"
    
    //MARK: - Header
    
    static var headerWithOutToken: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON
        ]
    }
    
    static var headerWithDeviceToken: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON,
            NetworkHeaderKey.authorization.rawValue: APIConstants.jwtToken
        ]
    }
    
    static var headerWithAuthorization: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON,
            NetworkHeaderKey.authorization.rawValue: URLConstant.bearer + APIConstants.accessToken
        ]
    }
    
    static var headerWithRefresh: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON,
            NetworkHeaderKey.authorization.rawValue: APIConstants.jwtToken
        ]
    }
}
