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
    case listeningList(_ email: String)
    case listenerList(_ email: String)
    case mypageTimeLine(_ email: String)
    case modifyprofile

    func path() -> String {

        switch self {
        case .profileValue(let email):
            return "/profile/\(email)"
        case .listeningList(let email):
            return " /profile\(email)"
        case .listenerList(let email):
            return "/profile\(email)"
        case .mypageTimeLine(let email):
            return "/profile\(email)"
        case .modifyprofile:
            return "/profile/"
        default:
            return ""

        }
    }

    func header() -> HTTPHeaders? {
        switch self {

        default:
            return ["Authorization" : "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDEzNTAyNzUsIm5iZiI6MTYwMTM1MDI3NSwianRpIjoiNjM1ZTk3OWItNjczZC00ZmI5LTg3MmEtZDE2MjdjNGQyYTBlIiwiZXhwIjoxNjA5OTkwMjc1LCJpZGVudGl0eSI6ImFkbWluQGdtYWlsLmNvbSIsImZyZXNoIjpmYWxzZSwidHlwZSI6ImFjY2VzcyJ9.3fLkBFWZ9N0Cq0xGEXZzVeKjNvkqkVdREsMOJwbtzy8"]
        }
    }

}
