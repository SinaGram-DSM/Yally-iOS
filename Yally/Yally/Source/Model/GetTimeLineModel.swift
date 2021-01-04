//
//  GetTimeLineModel.swift
//  Yally
//
//  Created by 문지수 on 2021/01/02.
//

import Foundation

import RxSwift
import RxCocoa

struct posts: Codable {
    var posts: [MainModel] = [MainModel]()
}

struct MainModel: Codable {
    let id: String
    let user: User
    let content: String
    let sound: String?
    let img: String
    let comment: Int
    let yally: Int
    let isYally: Bool
    let createdAt: String
    let isMine: Bool
}

struct User: Codable {
    let email: String
    let nickname: String
    let img: String
}
