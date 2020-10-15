//
//  AuthAPI.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import Foundation
import RxSwift

class AuthAPI {
    private let httpClient = HTTPClient()

    func postAuthCode(_ userEmail: String) {
        httpClient.post(path: YallyURL.authCode.path(),
                        param: ["email": userEmail],
                        headers: YallyURL.authCode.headers())
            .responseJSON { (response) in
                switch response.response?.statusCode {
                case 200:
                    print("Auth Code Success")
                case 409:
                    print("Overlap Email")
                default:
                    print(response.result)
                }
            }
    }

    func postConfirmCode(_ email: String, _ code: String) {
        httpClient.post(path: YallyURL.authConfirm.path(), param: ["email": email, "code": code], headers: YallyURL.authConfirm.headers())
            .responseJSON { (response) in
                print(email)
                print(code)
                switch response.response?.statusCode {
                case 200:
                    print("Correct User")
                case 401:
                    print("Wrong Code")
                default:
                    print(response.response?.statusCode ?? "statusCode")
                    print("Another mission")
                }
            }
    }

    func postSignUp(_ userEmail: String, _ userAge: Int, _ userName: String, _ userRepw: String) {
        httpClient.post(path: YallyURL.signUp.path(),
                        param: ["email": userEmail,
                                "password": userRepw,
                                "nickname": userName,
                                "age": userAge],
                        headers: YallyURL.signUp.headers())
            .responseJSON { (response) in
                switch response.response?.statusCode {
                case 201:
                    print("Create New User")
                case 409:
                    print("Overlap User")
                default:
                    print("Another mission")
                }
            }
    }

        func postSignIn(_ userEmail: String, _ userPw: String) {
            httpClient.post(path: YallyURL.signIn.path(),
                            param: ["email": userEmail,
                                    "password": userPw],
                            headers: YallyURL.signIn.headers())
                .responseJSON { (response) in
                    switch response.response?.statusCode {
                    case 200:
                        print("Login Success")
                        guard let value = response.data else { return }
                        guard let data = try? JSONDecoder().decode(User.self, from: value) else { return }
                    case 404:
                        print("No User")
                    default:
                        print("Another mission")
                    }
                }
        }

}
