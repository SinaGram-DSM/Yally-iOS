//
//  AuthAPI.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import Foundation
import RxSwift

final class AuthAPI {
    private let request = HTTPClient()

    func postAuthCode(userEmail: String) -> Observable<StatusCode> {
        request.post(.authCode, params: ["userEmail": userEmail])
            .map { (response, _) -> StatusCode in
                switch response.statusCode {
                case 200:
                    print("Auth Code Success")
                    return .ok
                case 409:
                    print("Overlap userEmail")
                    return .overlap
                default:
                    print("")
                    return .fault
                }
            }
    }

    func postConfirmCode(code: String, userEmail: String) -> Observable<StatusCode> {
        request.post(.authConfirm, params: ["userEmail": userEmail, "code": code])
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

    func postSignUp(userEmail: String, userAge: Int, userName: String, userRepw: String) -> Observable<StatusCode> {
        request.post(.signUp, params: ["userEmail": userEmail,
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

    func postSignIn(userEmail: String, userPw: String) -> Observable<StatusCode> {
        request.post(.signIn, params: ["userEmail": userEmail,
                                       "password": userPw])
            .map { (response, data) -> StatusCode in
                switch response.statusCode {
                case 200:
                    print("Login Success")
                    guard let token = try? JSONDecoder().decode(Token.self, from: data) else { return .fault }

                    let user = User(email: userEmail, password: userPw, token: token)

                    if TokenUtils.shared.readUser() != nil && TokenUtils.shared.updateUser(user) {
                        return .ok
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

    func postResetPw(userEmail: String) -> Observable<StatusCode> {
        request.post(.resetCodeToEmail, params: ["userEmail": userEmail]).map { (response, _) -> StatusCode in
            switch response.statusCode {
            case 200:
                return .ok
            default:
                return .fault
            }
        }
    }

    func putNewPw(userEmail: String, code: String, password: String) -> Observable<StatusCode> {
        request.put(.modifyPassword, params: ["userEmail": userEmail, "code": code, "password" : password]).map { response, _ -> StatusCode in
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
