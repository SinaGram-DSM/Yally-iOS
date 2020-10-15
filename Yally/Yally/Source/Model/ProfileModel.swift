//
//  ProfileModel.swift
//  Yally
//
//  Created by 문지수 on 2020/10/09.
//

import Foundation

struct ProfileModel: Codable {
    let profileImage: String
    let nickname:String
    let listening: Int
    let listener: Int
    let email: String
}
