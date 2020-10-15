//
//  TimeLineAPI.swift
//  Yally
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import RxSwift
import Alamofire

class TimeLineAPI {
    let baseURI = "http://13.125.238.84:81"
    private let httpClient = HTTPClient()

    func getTimeLine(_ page: Int) -> Observable<(posts?, StatusCode)> {
        httpClient.get(.timeLine(page), params: nil).map { (response, data) -> (posts?, StatusCode) in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode(posts.self, from: data) else { return (nil, .fault)}

                return  (data, .ok)
            case 404:
                return (nil, .noHere)
            default:
                return (nil, .fault)
            }
        }
    }

    func postFormData(_ api: YallyURL, param: [String:Any], _ sound: URL, _ img: Data?) -> DataRequest {
        let urlStr = "\(sound)"
        let pathArr = urlStr.components(separatedBy: "/")
        let fileName = String(pathArr.last!)

        return AF.upload(multipartFormData: { (multipartFormData) in
            do {
                let audioData = try Data(contentsOf: sound)

                multipartFormData.append(audioData, withName: "sound", fileName: fileName, mimeType: "audio/aac")
            } catch {
                print(error)
            }
            if img != nil {
                multipartFormData.append(img!, withName: "img", fileName: "backImg", mimeType: "image/jpg")
            }

            for (key, value) in param {
                if key == "hashtag" {
                    let arrayObj = value as! [Any]
                    for i in 0..<arrayObj.count {
                        let value = arrayObj[i] as! String
                        print("\(key) \(value)")
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
                }
            }
        }, to: baseURI + api.path, method: .post, headers: api.header)
    }

    func postDetailPost(_ id: String) -> Observable<(DetailModel?, StatusCode)> {
        httpClient.get(.detailPost(id: id), params: nil).map { (response, data) -> (DetailModel?, StatusCode) in
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode(DetailModel.self, from: data) else { return (nil, .fault) }
                return (data, .ok)
            case 404:
                return (nil, .noHere)
            default:
                return (nil, .fault)
            }
        }
    }

    func postDetailComment(_ id: String) -> Observable<(CommentModel?, StatusCode)> {
        httpClient.get(.detailPostComment(id: id), params: nil).map {response, data -> (CommentModel?, StatusCode) in
            switch response.statusCode {
            case 200:
                guard let data = try? JSONDecoder().decode(CommentModel?.self, from: data) else { return (nil, .fault)}

                return (data, .ok)
            default:
                return (nil, .fault)
            }
        }
    }

    func deletePost(_ id: String) -> Observable<StatusCode> {
        httpClient.delete(.deletePost(id: id), params: nil).catchError { error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://13.125.238.84:81")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map {response, _ -> StatusCode in
            switch response.statusCode {
            case 204:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func updatePost(_ sound: String, _ content: String, _ img: String, _ hashtag: String, _ id: String) -> Observable<StatusCode> {
        httpClient.put(.updatePost(id: id), params: ["sound":sound, "content":content, "img":img, "hashtag":hashtag]).map {response, _ -> StatusCode in
            switch response.statusCode {
            case 201:
                return .ok1
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func postComment(_ api: YallyURL, _ sound: URL?, _ content: String) -> DataRequest {
        var pathArr = [String]()
        var fileName = String()

        if sound != nil {
            let urlStr = "\(sound!)"
            pathArr = urlStr.components(separatedBy: "/")
            fileName = String(pathArr.last!)
        }

            return AF.upload(multipartFormData: { (multipartFormData) in
                do {
                    if sound != nil {
                        let audioData = try Data(contentsOf: sound!)

                        multipartFormData.append(audioData, withName: "file", fileName: fileName, mimeType: "audio/aac")
                    }
                } catch {
                    print(error)
                }

                multipartFormData.append(content.data(using: .utf8)!, withName: "content", mimeType: "text/plain")

            }, to: baseURI + api.path, method: .post, headers: api.header)
    }

    func deleteComment(_ id: String) -> Observable<StatusCode> {
        httpClient.delete(.deleteComment(id), params: nil).catchError { error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://13.125.238.84:81")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map {response, _ -> StatusCode in
            print(response.statusCode)
            switch response.statusCode {
            case 204:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func postYally(_ id: String) -> Observable<StatusCode> {
        httpClient.get(.postYally(id: id), params: nil).catchError { error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://13.125.238.84:81")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map {response, _ -> StatusCode in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func deleteYally(_ id: String) -> Observable<StatusCode> {
        httpClient.delete(.cancelYally(id: id), params: nil).catchError { error -> Observable<(HTTPURLResponse, Data)> in
            guard let afError = error.asAFError else { return .error(error) }
            switch afError {
            case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
              let response = HTTPURLResponse(
                url: URL(string: "http://10.156.145.141:8080")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
              )
                return .just((response!, Data(base64Encoded: "")!))
            default:
              return .error(error)
            }
          }.map {response, _ -> StatusCode in
            print(response.statusCode)
            switch response.statusCode {
            case 204:
                return .ok
            case 404:
                return .noHere
            default:
                return .fault
            }
        }
    }

    func uploadFormData(_ api: YallyURL, param: [String:Any], _ sound: URL, _ img: Data?) -> DataRequest {
        let urlStr = "\(sound)"
        let pathArr = urlStr.components(separatedBy: "/")
        let fileName = String(pathArr.last!)

        return AF.upload(multipartFormData: { (multipartFormData) in
            do {
                let audioData = try Data(contentsOf: sound)

                multipartFormData.append(audioData, withName: "sound", fileName: fileName, mimeType: "audio/aac")
            } catch {
                print(error)
            }

            if img != nil {
                multipartFormData.append(img!, withName: "img", fileName: "backImg", mimeType: "image/jpg")
            }

            for (key, value) in param {
                if key == "hashtag" {
                    let arrayObj = value as! [Any]
                    for i in 0..<arrayObj.count {
                        let value = arrayObj[i] as! String
                        print("\(key) \(value)")
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                } else {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
                }
            }
        }, to: baseURI + api.path, method: .put, headers: api.header)
    }
}
