//
//  ProfileAPI.swift
//  Yally
//
//  Created by 문지수 on 2020/10/03.
//

import Foundation

import RxSwift
import RxCocoa
import Alamofire

class ProfileAPI {
    private let httpClient = HTTPClient()
    let baseURL = "http://13.125.238.84:81/"

    func getProfileValue(_ email: String) -> Observable<(ProfileModel?, StatusCode)> {
        return httpClient.get(api: .profileValue(email), param: nil)
            .map { (response, data) -> (ProfileModel?, StatusCode) in
                switch response.statusCode {
                case 200:
                   guard let data = try? JSONDecoder().decode(ProfileModel.self, from: data) else { return  (nil, .fault) }

                    return (data, .ok)
                case 404:
                    return (nil, .noHere)
                default:
                    return (nil, .fault)
                }
            }
        }

    func getListenigList(_ email: String) -> Observable<(listen?, StatusCode)> {
        return httpClient.get(api: .listeningList(email), param: nil)
            .map { (response, data) -> (listen?, StatusCode) in
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode(listen.self, from: data) else { return(nil, .fault)
                    }
                    return (data, .ok)

                case 404:
                    return (nil, .noHere)
                default:
                    return (nil, .fault)
                }
            }

        }

    func getListenerList(_ email: String) -> Observable<(listen?, StatusCode)> {
        return httpClient.get(api: .listenerList(email), param: nil)
            .map { (response, data) -> (listen?, StatusCode) in
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode(listen.self, from: data) else {
                        return (nil, .fault)
                    }
                    return (data, .ok)
                case 404:
                    return (nil, .noHere)
                default:
                    return (nil, .fault)
                }
            }
    }

    func getMypageTimeLine(_ email: String) -> Observable<(ProfileModel?, StatusCode)> {
        return httpClient.get(api: .mypageTimeLine(email), param: nil)
            .map { (response, _) -> (ProfileModel?, StatusCode) in
                switch response.statusCode {
                case 404:
                    return (nil, .noHere)
                default:
                    return (nil, .fault)
                }
            }
    }
    
    func putModifyProfile() -> Observable<(ProfileModel?, StatusCode)> {
        return httpClient.put(api: .modifyprofile, params: nil)
            .map{ (response, data) -> (ProfileModel?, StatusCode) in
                switch response.statusCode {
                case 201:
                    guard let data = try? JSONDecoder().decode(ProfileModel.self, from: data) else {
                        return (nil, .fault)
                    }
                    return (nil, .ok)
                case 404:
                    return (nil, .noHere)
                default:
                    return (nil, .fault)
                }
            }
    }
    
    func getTimeLine(_ email: String, _ page: Int) -> Observable<(posts?, StatusCode)> {
        return httpClient.get(api: .profileTimeLine(email, page), param: nil)
            .map { (response, data) -> (posts?, StatusCode) in
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode(posts.self, from: data) else {
                        return (nil, .fault)
                    }
                    return (data, .ok)
                case 404:
                    return (nil, .noHere)
                default:
                    return (nil, .fault)
                }
            }
    }

    func formData(_ api: YallyURL, param: Parameters, img: Data?) -> DataRequest {
            return AF.upload(multipartFormData: { (multipartFormData) in
                if img != nil {
                    multipartFormData.append(img!, withName: "img", fileName: "image.jpg", mimeType: "image/jpg")
                }
                for (key, value) in param {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
                }
            }, to: baseURL + api.path(), method: .post, headers: api.header())
        }

}

