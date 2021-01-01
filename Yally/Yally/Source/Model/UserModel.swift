//
//  UserModel.swift
//  Yally
//
//  Created by 문지수 on 2020/11/12.
//

import Foundation

struct UserModel: Codable {
    let nickname: String
    let image: String
    let listener: String
    let listening: String
    let isListening: Bool
}
