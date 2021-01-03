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

    func postAuthCode(_ userEmail: String) -> Observable<StatusCode> {
        httpClient.post(.authCode, params: ["email": userEmail])
            .map { (response, _) -> StatusCode in
                switch response.statusCode {
                case 200:
                    print("Auth Code Success")
                    return .ok
                case 409:
                    print("Overlap Email")
                    return .overlap
                default:
                    print("")
                    return .fault
                }
            }
    }

    func postConfirmCode(_ email: String, _ code: String) -> Observable<StatusCode> {
        httpClient.post(.authConfirm, params: ["email": email, "code": code])
            .map { (response, _) -> StatusCode in
                print(response.statusCode)
                print(code)
                switch response.statusCode {
                case 200:
                    print("Correct User")
                    return .ok
                case 401:
                    print("Wrong Code")
                    return .unauthorized
                default:
                    print("Another mission")
                    return .fault
                }
            }
    }

    func postSignUp(_ userEmail: String, _ userAge: Int, _ userName: String, _ userRepw: String) -> Observable<StatusCode> {
        httpClient.post(.signUp, params: ["email": userEmail,
                                          "password": userRepw,
                                          "nickname": userName,
                                          "age": userAge])
            .map { (response, _) -> StatusCode in
                switch response.statusCode {
                case 201:
                    print("Create New User")
                    return .ok
                case 409:
                    print("Overlap User")
                    return .overlap
                default:
                    print(response.statusCode)
                    print("Another mission")
                    return .fault
                }
            }
    }

        func postSignIn(_ userEmail: String, _ userPw: String) -> Observable<StatusCode> {
            httpClient.post(.signIn, params: ["email": userEmail,
                                              "password": userPw])
                .map { (response, data) -> StatusCode in
                    switch response.statusCode {
                    case 200:
                        print("Login Success")
                        guard let token = try? JSONDecoder().decode(Token.self, from: data) else { return .fault }
                        let user = User(email: userEmail, password: userPw, token: token)

                        if TokenUtils.shared.readUser() != nil {
                            if TokenUtils.shared.updateUser(user) { return .ok }
                        }

                        if TokenUtils.shared.createUser(user) { return .ok }

                        print("Return fault")
                        return .fault
                    case 404:
                        print("No User")
                        return .noHere
                    default:
                        print("Another mission")
                        return .fault
                    }
                }
        }

    func postResetPw(_ email: String) -> Observable<StatusCode> {
        httpClient.post(.resetCodeToEmail, params: ["email": email]).map { (response, _) -> StatusCode in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }

    func putNewPw(_ email: String, _ code: String, _ password: String) -> Observable<StatusCode> {
        httpClient.put(.modifyPassword, params: ["email": email, "code": code, "password" : password]).map { response, _ -> StatusCode in
            print(response.statusCode)
            switch response.statusCode {
            case 200:
                return .ok
            case 401:
                return .JWTdeadline
            default:
                return .fault
            }
        }
    }

}
