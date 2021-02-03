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

    func get(_ url: YallyURL, params: [String:Any]? = nil) -> HTTPResult {
        return requestData(.get, baseURI + url.path, parameters: params, encoding: URLEncoding.queryString, headers: url.headers())
    }

    func put(_ url: YallyURL, params: [String:Any]? = nil) -> HTTPResult {
        return requestData(.put, baseURI + url.path, parameters: params, encoding: URLEncoding.queryString, headers: url.headers())
    }
    
    func post(_ url: YallyURL, params: [String:Any]? = nil) -> HTTPResult {
        return requestData(.post, baseURI + url.path, parameters: params, encoding: URLEncoding.queryString, headers: url.headers())
    }

    func delete(_ url: YallyURL, params: [String:Any]? = nil) -> HTTPResult {
        return requestData(.delete, baseURI + url.path, parameters: params, encoding: URLEncoding.queryString, headers: url.headers())
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
