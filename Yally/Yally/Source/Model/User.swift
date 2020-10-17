//
//  User.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import Foundation

struct User: Codable {
    var email: String
    var password: String
    var token: Token
}
