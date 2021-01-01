//
//  HTTPClient.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift

class HTTPClient {
    let baseURI = "http://13.125.238.84:81"

    typealias HttpResult = Observable<(HTTPURLResponse, Data)>

    func get(api: YallyURL, param: [String: Any]?) -> HttpResult {
        return requestData(.get, baseURI + api.path(), parameters: param, headers: api.header())
    }

    func put(api: YallyURL, params: [String:Any]?) -> HttpResult {
        //return requestData(.put, baseURI + api.path(), parameters: params, encoding: URLEncoding.queryString, headers: api.header())
        
        return requestData(.put, baseURI + api.path(), parameters: params, headers: api.header())
      }

    func delete(api: YallyURL, params: [String: Any]?) -> HttpResult {
        return requestData(.delete, baseURI + api.path(), parameters: params, encoding: JSONEncoding.prettyPrinted, headers: api.header())
    }

    func post(api: YallyURL, params: [String: Any]?) -> HttpResult {
        return requestData(.post, baseURI + api.path(), parameters: params, encoding: JSONEncoding.prettyPrinted, headers: api.header())
    }
}

enum StatusCode: Int {
    case ok = 200
    case success = 201
    case unauthorized = 401
    case overlap = 409
    case JWTdeadline = 403
    case noHere = 404
    case wrongType = 422
    case badReqeust = 400
    case fault = 0
}
