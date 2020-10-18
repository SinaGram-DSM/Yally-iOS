//
//  YallyURL.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation
import Alamofire

enum YallyURL {
    case timeLine
    case createPost
    case detailPost
    case detailPostComment
    case deletePost
    case updatePost
    case postComment
    case deleteComment
    case postYally
    case cancelYally

    var path: String {
        switch self {
        case .timeLine:
            return "/timeline/<int:page>"
        case .createPost:
            return "/post"
        case .detailPost, .deletePost, .updatePost:
            return "/post/<id>"
        case .detailPostComment:
            return "/post/<id>/comment"
        case .postComment:
            return "/post/commnet/<id>"
        case .deleteComment:
            return "/post/commnet/<commentId"
        case .postYally, .cancelYally:
            return "/post/yally/<id>"
        }
    }

    var header: HTTPHeaders? {
        switch self {
        default:
            return ["Authorization" : "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDEzNTAyNzUsIm5iZiI6MTYwMTM1MDI3NSwianRpIjoiNjM1ZTk3OWItNjczZC00ZmI5LTg3MmEtZDE2MjdjNGQyYTBlIiwiZXhwIjoxNjA5OTkwMjc1LCJpZGVudGl0eSI6ImFkbWluQGdtYWlsLmNvbSIsImZyZXNoIjpmYWxzZSwidHlwZSI6ImFjY2VzcyJ9.3fLkBFWZ9N0Cq0xGEXZzVeKjNvkqkVdREsMOJwbtzy8"]
        }
    }
}
