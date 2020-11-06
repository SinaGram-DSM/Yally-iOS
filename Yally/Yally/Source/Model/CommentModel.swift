//
//  Comment.swift
//  Yally
//
//  Created by 이가영 on 2020/11/01.
//

import Foundation

class Comment: Codable {
    let user: User
    let id: String
    let content: String
    let sound: String
    let createAt: String
    let isMine: Bool
}

class CommentModel: Codable {
    let comments: [Comment]
}
