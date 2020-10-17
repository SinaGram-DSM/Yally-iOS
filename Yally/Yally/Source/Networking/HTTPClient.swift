//
//  HTTPClient.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation
import RxAlamofire
import RxSwift
import Alamofire

class HTTPClient {
    let baseURI = "http://13.125.238.84:81"

    typealias HttpResult = Observable<(HTTPURLResponse, Data)>

    func get(_ api: YallyURL, params: [String: Any]) -> HttpResult {
        return requestData(.get, baseURI + api.path(),
                           parameters: params,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.headers())
    }

    func post(_ api: YallyURL, params: [String: Any]) -> HttpResult {
        return requestData(.post, baseURI + api.path(),
                           parameters: params,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.headers())
    }

    func put(_ api: YallyURL, params: [String: Any]) -> HttpResult {
        return requestData(.put, baseURI + api.path(),
                           parameters: params,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.headers())
    }

    func delete(_ api: YallyURL, params: [String: Any]) -> HttpResult {
        return requestData(.delete, baseURI + api.path(),
                           parameters: params,
                           encoding: JSONEncoding.prettyPrinted,
                           headers: api.headers())
    }
}

enum StatusCode: Int {
    case ok = 200
    case ok1 = 201
    case unauthorized = 401
    case overlap = 409
    case JWTdeadline = 403
    case noHere = 404
    case wrongType = 422
    case badReqeust = 400
    case serverError = 500
    case fault = 0
}
