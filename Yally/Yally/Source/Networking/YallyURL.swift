//
//  YallyURL.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation
import Alamofire

enum YallyURL {
    case timeLine(_ page: Int)
    case createPost
    case detailPost(id: String)
    case detailPostComment(id: String)
    case deletePost(id: String)
    case updatePost(id: String)
    case postComment
    case deleteComment(_ id: String)
    case postYally(id: String)
    case cancelYally(id: String)

    var path: String {
        switch self {
        case .timeLine(let page):
            return "/timeline/\(page)"
        case .createPost:
            return "/post"
        case .detailPost(let id), .deletePost(let id), .updatePost(let id):
            return "/post/\(id)"
        case .detailPostComment(let id):
            return "/post/\(id)/comment"
        case .postComment:
            return "/post/commnet/<id>"
        case .deleteComment(let id):
            return "/post/commnet/\(id)"
        case .postYally(let id), .cancelYally(let id):
            return "/post/yally/\(id)"
        }
    }

    var header: HTTPHeaders? {
        switch self {
        default:
            return ["Authorization" : "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDEzNTAyNzUsIm5iZiI6MTYwMTM1MDI3NSwianRpIjoiNjM1ZTk3OWItNjczZC00ZmI5LTg3MmEtZDE2MjdjNGQyYTBlIiwiZXhwIjoxNjA5OTkwMjc1LCJpZGVudGl0eSI6ImFkbWluQGdtYWlsLmNvbSIsImZyZXNoIjpmYWxzZSwidHlwZSI6ImFjY2VzcyJ9.3fLkBFWZ9N0Cq0xGEXZzVeKjNvkqkVdREsMOJwbtzy8"]
        }
    }
}
