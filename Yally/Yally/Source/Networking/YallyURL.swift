//
//  YallyURL.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation
import Alamofire

enum YallyURL {
    case signIn
    case authCode
    case authConfirm
    case signUp
    case resetCodeToEmail
    case modifyPassword
    case refreshToken
    case timeLine(_ page: Int)
    case createPost
    case detailPost(id: String)
    case detailPostComment(id: String)
    case deletePost(id: String)
    case updatePost(id: String)
    case postComment(_ id: String)
    case deleteComment(_ id: String)
    case postYally(id: String)
    case cancelYally(id: String)

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
        case .timeLine(let page):
            return "/timeline/\(page)"
        case .createPost:
            return "/post"
        case .detailPost(let id), .deletePost(let id), .updatePost(let id):
            return "/post/\(id)"
        case .detailPostComment(let id):
            return "/post/\(id)/comment"
        case .postComment(let id):
            return "/post/comment/\(id)"
        case .deleteComment(let commentid):
            return "/post/comment/\(commentid)"
        case .postYally(let id), .cancelYally(let id):
            return "/post/yally/\(id)"
        }
    }

    func headers() -> HTTPHeaders? {
        switch self {
        case .signUp, .authCode, .authConfirm, .resetCodeToEmail, .modifyPassword:
            return nil
        case .refreshToken:
            guard let token = TokenManager.currentToken?.refreshToken else { return nil }
            return ["Authorization" : "Bearer " + token]
        default:
            guard let token = TokenManager.currentToken?.accessToken else { return nil }
            return ["Authorization" : "Bearer " + token]
        }
    }
}
