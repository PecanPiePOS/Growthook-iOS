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
    case refreshToken = "refreshToken"
    case contentType = "Content-Type"
    case authorization = "Authorization"
}

enum APIConstants {
    
    static let accept: String = "Accept"
    static let auth: String = "x-auth-token"
    static let applicationJSON = "application/json"
    static var deviceToken: String = ""
    static var jwtToken: String = KeychainHelper.loadString(key: I18N.Auth.jwtToken) ?? ""
    static var refreshToken: String = KeychainHelper.loadString(key: I18N.Auth.refreshToken) ?? ""
    
    //MARK: - Header
    
    static var headerWithOutToken: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON
        ]
    }
    
    static var headerWithDeviceToken: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON,
            NetworkHeaderKey.authorization.rawValue: URLConstant.bearer + APIConstants.deviceToken
        ]
    }
    
    static var headerWithAuthorization: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON,
            NetworkHeaderKey.authorization.rawValue: URLConstant.bearer + APIConstants.jwtToken
        ]
    }
    
    static var headerWithRefresh: [String: String] {
        [
            NetworkHeaderKey.contentType.rawValue: APIConstants.applicationJSON,
            NetworkHeaderKey.authorization.rawValue: URLConstant.bearer + APIConstants.jwtToken,
            NetworkHeaderKey.refreshToken.rawValue: URLConstant.bearer + APIConstants.refreshToken
        ]
    }
}
