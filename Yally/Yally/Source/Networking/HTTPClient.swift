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

    func get(_ api: YallyURL, params: [String:Any]?) -> HttpResult {
        return requestData(.get, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }

    func put(_ api: YallyURL, params: [String:Any]?) -> HttpResult {
        return requestData(.put, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }

    func post(_ api: YallyURL, params: [String:Any]?) -> HttpResult {
        return requestData(.post, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }

    func delete(_ api: YallyURL, params: [String:Any]?) -> HttpResult {
        return requestData(.delete, baseURI + api.path, parameters: params, encoding: URLEncoding.queryString, headers: api.header)
    }

    func postFormData(_ api: YallyURL, param: [String:Any], _ sound: URL, _ img: Data?) -> DataRequest {
        let urlStr = "\(sound)"
        let pathArr = urlStr.components(separatedBy: "/")
        let fileName = String(pathArr.last!)

        return AF.upload(multipartFormData: { (multipartFormData) in
            do {
                let audioData = try Data(contentsOf: sound)

                multipartFormData.append(audioData, withName: "sound", fileName: fileName, mimeType: "audio/aac")
                print(audioData)
            } catch {
                print(error)
            }
            if img != nil {
                multipartFormData.append(img!, withName: "img", mimeType: "image/jpg")
            }
            for (key, value) in param { multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain") }

        }, to: baseURI + api.path, method: .post, headers: api.header)
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
    case fault = 0
}
