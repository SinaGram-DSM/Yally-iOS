//
//  HTTPClient.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation
import Alamofire

class HTTPClient {

    let baseURI = "http://13.125.238.84:81"

    func get(path: String, param: [String: Any], headers: [String:String]) -> DataRequest {
        return AF.request(baseURI + path, method: .get, parameters: param, encoding: JSONEncoding.prettyPrinted, headers: HTTPHeaders(headers), interceptor: nil)
    }

    func put(path: String, param: [String: Any], headers: [String:String]) -> DataRequest {
        return AF.request(baseURI + path, method: .put, parameters: param, encoding: JSONEncoding.prettyPrinted, headers: HTTPHeaders(headers), interceptor: nil)
    }

    func delete(path: String, param: [String: Any], headers: [String:String]) -> DataRequest {
        return AF.request(baseURI + path, method: .delete, parameters: param, encoding: JSONEncoding.prettyPrinted, headers: HTTPHeaders(headers), interceptor: nil)
    }

    func post(path: String, param: [String: Any], headers: [String:String]) -> DataRequest {
        return AF.request(baseURI + path, method: .post, parameters: param, encoding: JSONEncoding.prettyPrinted, headers: HTTPHeaders(headers), interceptor: nil)
    }
}

enum StatusCode: Int {
    case ok = 200
    case unauthorized = 401
    case overlap = 409
    case JWTdeadline = 403
    case noHere = 404
    case wrongType = 422
    case badReqeust = 400

}
