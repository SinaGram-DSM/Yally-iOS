//
//  ListenModel.swift
//  Yally
//
//  Created by 문지수 on 2020/12/15.
//

import Foundation

import RxSwift
import RxCocoa

class target: Codable {
    let nickname: String
    let image: String
    let listening: Int
    let listener: Int
    let isMine: Bool
}

class listen: Codable {
    let listen: [listenings]
}

class listenings: Codable {
    let nickname:  String
    let image: String
    let listener: Int
    let listening: Int
    let isListening: Int
}
