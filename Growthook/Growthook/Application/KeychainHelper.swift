//
//  KeychainHelper.swift
//  Growthook
//
//  Created by 천성우 on 1/24/24.
//

import Foundation

import Security

class KeychainHelper {

    static func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func update(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }

    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var data: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &data)

        if status == noErr {
            return data as? Data
        } else {
            return nil
        }
    }
    
    static func loadString(key: String) -> String? {
        if let data = load(key: key) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

