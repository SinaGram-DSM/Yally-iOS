//
//  ViewModelType.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import Foundation

protocol ViewModelType {
    associatedtype input
    associatedtype output

    func transform(_ input: input) -> output
}
