//
//  YallyURL.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation

import RxSwift
import RxCocoa
import Alamofire

enum YallyURL {

    case profileValue(_ email: String)
    case modifyProfile(_ nickname: String, _ image: String)
    case listeningList(_ email: String)
    case listenerList(_ email: String)

    func path() -> String {

        switch self {
        case .profileValue(let email):
            return "/profile/\(email)"
        case .modifyProfile(let nickname, let image):
            return " /profile "
        case .listeningList(let email):
            return " /profile\(email)"
        case .listenerList(let email):
            return "/profile\(email)"
        default:
            return ""

        }
    }

    func header() -> HTTPHeaders? {
        switch self {
        case .profileValue:
            return ["":""]

        default:
            return nil
        }
    }

}
