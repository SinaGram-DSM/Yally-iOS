//
//  MainModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/25.
//

import Foundation

struct Posts: Codable {
    var posts: [MainModel] = [MainModel]()
}

struct MainModel: Codable {
    let id: String
    let content: String
    let sound: String
    let img: String?
    let createdAt: String
    let user: MainUser
    let comment: Int
    let yally: Int
    var isYally: Bool
    let isMine: Bool
}

struct MainUser: Codable {
    let email: String
    let nickname: String
    let img: String
}

struct DetailModel: Codable {
    let content: String
    let sound: String
    let img: String?
    let createdAt: String
    let user: DetailUser
    let comment: Int
    let yally: Int
    var isYally: Bool
    let isMine: Bool
}

struct DetailUser: Codable {
    let nickname: String
    let img: String
}
