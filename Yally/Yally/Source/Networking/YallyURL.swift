//
//  YallyURL.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation

enum YallyURL {
    case listeningValue
    case listenerValue

    func path() -> String {
        let baseURL = "http://13.125.238.84:81"
        switch self {
        case .listeningValue:
            return baseURL + "/profile/<email>"
        case .listenerValue:
            return baseURL + "/profile/<email>"
        }
    }

}
