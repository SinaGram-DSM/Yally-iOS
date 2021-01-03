//
//  SignInViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/15.
//

import Foundation
import RxSwift
import RxCocoa

class SignInViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let userEmail: Driver<String>
        let userPw: Driver<String>
        let doneTap: Signal<Void>
    }

    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
    }

    func transform(_ input: SignInViewModel.input) -> SignInViewModel.output {
        let api = AuthAPI()
        let info = Driver.combineLatest( input.userEmail, input.userPw )
        let result = PublishSubject<String>()
        let isEnable = info.map { YallyFilter.checkEmpty($0.0) && YallyFilter.checkEmpty($0.1) }

        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { (userEmail, userPw) in
            api.postSignIn(userEmail, userPw).subscribe(onNext: { (response) in
                print(response)
                switch response {
                case .ok: result.onCompleted()
                case .noHere: result.onNext("유효하지 않은 이메일")
                default: result.onNext("로그인 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "로그인 실패패"))
    }
}
