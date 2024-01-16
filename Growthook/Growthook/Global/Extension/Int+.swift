//
//  Int+.swift
//  Growthook
//
//  Created by Minjoo Kim on 1/14/24.
//

import Foundation

/// Int를 00 형태의 String으로 변환합니다. ex 03
extension Int {
    func toTwoDigitsString() -> String {
        if self < 10 {
            return "0\(self)"
        }
        else { return "\(self)" }
    }
}
