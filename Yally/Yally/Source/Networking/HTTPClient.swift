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
import RxAlamofire
import RxSwift

class HTTPClient {
    let baseURI = "HTTP://13.125.238.84:81"

    typealias HTTPResult = Observable<(HTTPURLResponse, Data)>

    func get(_ url: YallyURL, params: [String:Any]?) -> HTTPResult {
        return requestData(.get, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }

    func put(_ url: YallyURL, params: [String:Any]?) -> HTTPResult {
        return requestData(.put, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }

    func post(_ url: YallyURL, params: [String:Any]?) -> HTTPResult {
        return requestData(.post, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }

    func delete(_ url: YallyURL, params: [String:Any]?) -> HTTPResult {
        return requestData(.delete, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }
}

enum StatusCode: Int {
    case ok = 200
    case created = 201
    case unauthorized = 401
    case overlap = 409
    case JWTdeadline = 403
    case noHere = 404
    case wrongType = 422
    case badReqeust = 400
    case serverError = 500
    case fault = 0
}
