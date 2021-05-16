//
//  YallyFilter.swift
//  Yally
//
//  Created by 이가영 on 2021/01/20.
//

import Foundation

struct YallyFilter {
    static func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,30}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    static func checkPw(_ pw: String) -> Bool {
        let pwRegEx = "^(?=.*[a-zA-Z0-9])(?=.*[a-zA-Z!@#$%^&*])(?=.*[0-9!@#$%^&*]).{8,15}$"
        let pwTest = NSPredicate(format: "SELF MATCHES %@", pwRegEx)
        return pwTest.evaluate(with: pw)
    }
}
