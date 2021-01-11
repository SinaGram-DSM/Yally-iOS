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

    case profileValue(_ email: String)
    case listeningList(_ email: String)
    case listenerList(_ email: String)
    case mypageTimeLine(_ email: String)
    case modifyprofile
    case profileTimeLine(_ email: String, _ page: Int)

    func path() -> String {

        switch self {
        case .profileValue(let email):
            return "/profile/\(email)"
        case .listeningList(let email):
            return " /profile/\(email)"
        case .listenerList(let email):
            return "/profile/\(email)"
        case .mypageTimeLine(let email):
            return "/profile/\(email)"
        case .modifyprofile:
            return "/profile/"
        case .profileTimeLine(let email, let page):
            return "/mypage/timeline/\(email)/\(page)"

        default:
            return ""

        }
    }

    func header() -> HTTPHeaders? {
        switch self {

        case .modifyprofile:
            return ["Authorization" : "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDkwMDM2NDksIm5iZiI6MTYwOTAwMzY0OSwianRpIjoiN2Q4YzI0OTgtMDBiMy00ZTdiLTlhNzgtNTM1MjU5Nzg1MzBiIiwiZXhwIjoxNjE3NjQzNjQ5LCJpZGVudGl0eSI6ImFkbWluMTIzQGdtYWlsLmNvbSIsImZyZXNoIjpmYWxzZSwidHlwZSI6ImFjY2VzcyJ9.9GNR6d8v33lqNrg5UuljZRPN6fi-t7rNPCFO60VlVwM"]

        default:
            return ["Authorization" : "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDkwMDM2NDksIm5iZiI6MTYwOTAwMzY0OSwianRpIjoiN2Q4YzI0OTgtMDBiMy00ZTdiLTlhNzgtNTM1MjU5Nzg1MzBiIiwiZXhwIjoxNjE3NjQzNjQ5LCJpZGVudGl0eSI6ImFkbWluMTIzQGdtYWlsLmNvbSIsImZyZXNoIjpmYWxzZSwidHlwZSI6ImFjY2VzcyJ9.9GNR6d8v33lqNrg5UuljZRPN6fi-t7rNPCFO60VlVwM"]
        }
    }

}
