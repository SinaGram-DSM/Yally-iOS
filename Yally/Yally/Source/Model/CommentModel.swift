//
//  Comment.swift
//  Yally
//
//  Created by 이가영 on 2020/11/01.
//

import Foundation

class Comment: Codable {
    let user: MainUser
    let id: String
    let content: String
    let sound: String?
    let createdAt: String
    let isMine: Bool
}

class CommentModel: Codable {
    var comments: [Comment]
}
