//
//  ObservableType+.swift
//  Growthook
//
//  Created by KYUBO A. SHIM on 1/7/24.
//

import Foundation

import Moya
import RxSwift

extension Observable where Element == Response {
    
    /**
     Response 타입을 리턴하는 Observable 로써, statusCode 에 따라 구분합니다.
     */
    func mapError() -> Observable<Response> {
        flatMap { element -> Observable<Response> in
            .create { observer in
                switch element.statusCode {
                case 200...299:
                    observer.onNext(element)
                case 300...399:
                    print("👉🏻 Redirecting is Possible.")
                    observer.onNext(element)
                case 400:
                    observer.onError(ServiceError.invalidResponse(responseCode: element.statusCode, message: element.description))
                case 401:
                    observer.onError(ServiceError.tokenExpired)
                case 403...499:
                    // TODO: 여기서 지금 에러 메세지가 400 과 401 을 제외한 에러에 대한 정리본을 받지 못해 이렇게 퉁쳐놉니다.
                    observer.onError(ServiceError.invalidResponse(responseCode: element.statusCode, message: element.description))
                    print("❗️ Error Occurred.")
                default:
                    break
                }
                return Disposables.create()
            }
        }
    }
    
    /**
     해당 타입을 명시하여, 해당 타입으로 디코딩합니다.
     */
    func decode<Result: Codable>(decodeType: Result.Type) -> Observable<Result> {
        flatMap { element -> Observable<Result> in
            .create { observer in
                do {
                    guard let decoded = try JSONDecoder().decode(GeneralResponse<Result>.self, from: element.data).data else { return Disposables.create() }
                    observer.onNext(decoded)
                } catch let error {
                    print("❗️ Decoding Error")
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }

}

extension ObservableType where Element == Response {
    func retryOnTokenExpired(maxAttempts: Int = 2) -> Observable<Response> {
        return self.retry { errors in
            errors.enumerated().flatMap { (attempt, error) -> Observable<Void> in
                print("🔥")
                if let serviceError = error as? ServiceError, serviceError == .tokenExpired {
                    if attempt < maxAttempts - 1 {
                        // 토큰 갱신 로직을 실행하고, 성공하거나 실패해도 Void를 방출
                        return TokenManager.shared.refreshNewToken()
                            .catchAndReturn(()) // 토큰 갱신 실패 시 오류 대신 Void 방출
                    }
                }
                // 최대 재시도 횟수를 초과하거나 다른 오류의 경우 오류를 방출
                return Observable.error(error)
            }
        }
    }
}
