//
//  ProfileModel.swift
//  Yally
//
//  Created by 문지수 on 2020/10/09.
//

import Foundation

class ProfileModel: Codable {
    let nickname: String
    let image: Data
    let listener: Int
    let listening: Int
    let Listening: Bool
}

class Listening: Codable {
    let listening: [ProfileModel]
}
