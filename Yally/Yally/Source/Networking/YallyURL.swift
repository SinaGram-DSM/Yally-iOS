//
//  YallyURL.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation
import Security

enum YallyURL {
        case signIn
        case authCode
        case authConfirm
        case signUp
        case resetCodeToEmail
        case modifyPassword
        case refreshToken

//    case signIn(_ eamil: String, _ password: String)
//    case authCode(_ email: String)
//    case authConfirm(_ code: String)
//    case signUp(_ email: String, _ password: String, _ nickname: String, _ age: Int)
//    case resetCodeToEmail(_ email: String)
//    case modifyPassword(_ email: String, _ code: String, _ password: String)
//    case refreshToken

    func path() -> String {
        switch self {
        case .signIn:
            return "/user/auth"
        case .authCode:
            return "/user/auth-code/email"
        case .authConfirm:
            return "/user/code"
        case .signUp:
            return "/user"
        case .resetCodeToEmail:
            return "/user/reset-code/email"
        case .modifyPassword:
            return "/user/auth/password"
        case .refreshToken:
            return "/user/auth/refresh"
        }
    }

    func headers() -> [String: String]? {
        switch self {
        case .signUp, .authCode, .authConfirm, .resetCodeToEmail, .modifyPassword:
            return nil
        case .refreshToken:
            guard let token = currentToken?.refreshToken else { return nil }
            return ["Authorization": token]
        default:
            guard let token = currentToken?.accesstoekn else { return nil }
            return ["Authorization": token]
        }
    }
}
