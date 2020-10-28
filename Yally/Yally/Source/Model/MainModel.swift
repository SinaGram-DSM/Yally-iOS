//
//  MainModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/25.
//

import Foundation

struct posts: Codable {
    var posts: [MainModel] = [MainModel]()
}

struct MainModel: Codable {
    let id: String
    let content: String
    let sound: String
    let img: String?
    let createdAt: String
    let user: User
    let comment: Int
    let yally: Int
    let isYally: Bool
    let isMine: Bool
}

struct User: Codable {
    let email: String
    let nickname: String
    let img: String
}
