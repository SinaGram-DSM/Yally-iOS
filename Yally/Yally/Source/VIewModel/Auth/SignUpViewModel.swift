//
//  SignUpViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/15.
//

import Foundation
import RxSwift
import RxCocoa

class SignUpViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let userEmail: Driver<String>
        let userName: Driver<String>
        let userAge: Driver<Int>
        let userPw: Driver<String>
        let userRepw: Driver<String>
        let doneTap: Signal<Void>
    }

    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
    }

    func transform(_ input: input) -> output {
        let api = AuthAPI()
        let info = Driver.combineLatest(input.userEmail, input.userName, input.userAge, input.userPw, input.userRepw)
        let isEnable = info.map { YallyFilter.checkEmpty($0.1) && YallyFilter.checkEmpty($0.3) && YallyFilter.checkEmpty($0.4) &&
            YallyFilter.checkEmpty(String($0.2))
        }
        let result = PublishSubject<String>()

        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { userE, userN, userA, _, userR in
            api.postSignUp(userE, userA, userN, userR).subscribe(onNext: { response in
                switch response {
                case .ok: result.onCompleted()
                case .overlap: result.onNext("중복된 유저입니다.")
                default: result.onNext("회원가입 도중 문제가 발생하였습니다.")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "회원가입 실패"))
    }
}
