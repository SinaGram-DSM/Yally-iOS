//
//  ProfileAPI.swift
//  Yally
//
//  Created by 문지수 on 2020/10/03.
//

import Foundation

import RxSwift
import RxCocoa

class ProfileAPI {
    private let httpClient = HTTPClient()

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

    func putModifyProfile(_ nickname: String, _ image: String) -> Observable<StatusCode> {
        return httpClient.put(api: .modifyProfile(nickname, image), params: ["nickname" : nickname, "image" : image])
            .map { (response, _) -> (StatusCode) in
                switch response.statusCode {
                case 201:
                    return .ok
                case 404:
                    return .noHere
                default:
                    return .fault
                }
            }

    }

    func getListenigList(_ email: String) -> Observable<(ProfileModel?,StatusCode)> {
        return httpClient.get(api: .listeningList(email), param: nil)
            .map { (response, data) -> (ProfileModel?, StatusCode) in
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode(ProfileModel.self, from: data) else { return(nil, .fault)
                    }
                    return (data, .ok)

                case 404:
                    return (nil, .noHere)
                default:
                    return (nil, .fault)
                }
            }

        }

    func getListenerList(_ email: String) -> Observable<(ProfileModel?, StatusCode)> {
        return httpClient.get(api: .listenerList(email), param: nil)
            .map { (response, data) -> (ProfileModel?, StatusCode) in
                switch response.statusCode {
                case 200:
                    guard let data = try? JSONDecoder().decode(ProfileModel.self, from: data) else {
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
    }
