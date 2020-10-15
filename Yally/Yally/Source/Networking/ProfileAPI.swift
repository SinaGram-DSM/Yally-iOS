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
    
    func listeningValue(_ listening: Int) {
        return httpClient.get(path: YallyURL.listeningValue(listening), param: ["email": email], headers: nil)
            .map { (response, data) -> (ProfileModel?) in
                switch response.statusCode {
                case 200:
                    return .ok
                case 404:
                    return .noHere
                }
            }
    
    }

    func listenerValue(_ listener: Int) {
        return httpClient.get(path: YallyURL.listenerValue(listener), param: ["email": email], headers: nil)
            .map { (response, data) -> (ProfileModel?) in
                switch response.statusCode {
                case 200:
                    return .ok
                case 404:
                    return .noHere
                }
            }
    }
    


}

