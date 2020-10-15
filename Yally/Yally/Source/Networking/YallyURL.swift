//
//  YallyURL.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation

import Moya

enum YallyURL {
    case signIn(_ eamil: String, _ password: String)
    case authCode(_ email: String)
    case authConfirm(_ code: String)
    case signUp(_ email: String, _ password: String, _ nickname: String, _ age: Int)
    case resetCodeToEmail(_ email: String)
    case modifyPassword(_ email: String, _ code: String, _ password: String)
    case refreshToken
}

extension YallyURL: TargetType {
    var baseURL: URL {
        return URL(string: "http://13.125.238.84:81")!
    }
//        case signIn
//        case authCode
//        case authConfirm
//        case signUp
//        case resetCodeToEmail
//        case modifyPassword
//        case refreshToken



    var method: Moya.Method {
        switch self {
        case .signIn:
            return .get
        default:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .signIn:
            return "/user/auth"
        case .authCode:
            return "/user/auth-code/email"
        case .authConfirm:
            return "/user/auth-code"
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

    
    var task: Task {
        switch self {
        case .signIn(let email, let password):
            return .requestParameters(parameters: ["email": email, "password": password], encoding: JSONEncoding.prettyPrinted)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signUp, .authCode, .authConfirm, .resetCodeToEmail, .modifyPassword:
            return nil
        case .refreshToken:
            guard let token = TokenManager.currentToken?.refreshToken else { return nil }
            return ["Authorization" : "Bearer " + token]
        default:
            guard let token = TokenManager.currentToken?.accesstoekn else { return nil }
            return ["Authorization" : "Bearer " + token]
        }
    }
    
    var sampleData: Data{
        return Data()
    }
}
