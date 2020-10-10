//
//  SignInVIewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/05.
//

import Foundation
import RxCocoa
import RxSwift

class SignInViewModel: ViewModelType {
    private let disposeBag = DisposeBag()

    struct input {
        let userEmail: Driver<String>
        let userPw: Driver<String>
        let signInTap: Signal<Void>
    }

    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
    }

    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let info = Driver.combineLatest(input.userEmail, input.userPw)
        let isEnable = info.map { YallyFilter.checkEmpty($0.0) && YallyFilter.checkPwSignin($0.1)}
        let result = PublishSubject<String>()

        input.signInTap.withLatestFrom(info).asObservable()
            .subscribe(onNext: { (userE, userP) in
                api.postSignIn(userE, userP)
            }).disposed(by: disposeBag)

        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "로그인 실패"))
    }
}
