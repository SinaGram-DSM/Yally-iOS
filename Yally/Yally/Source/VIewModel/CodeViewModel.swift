//
//  AuthViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/04.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
class CodeViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let email: Driver<String>
        //var authCode: Driver<String>
        var doneTap: Signal<Void>
    }

    struct output {
        var isEnable: Driver<Bool>
        var result: Signal<String>
    }

    func transform(_ input: CodeViewModel.input) -> CodeViewModel.output {
        let api = AuthAPI()
        let info = input.email
        let isEnabled = info.map { YallyFilter.checkEmpty($0)}
        let result = PublishSubject<String>()

        input.doneTap.withLatestFrom(info)
            .asObservable().subscribe(onNext: { userEmail in
                api.postAuthCode(userEmail)
                result.onCompleted()
            }).disposed(by: disposeBag)

        return output(isEnable: isEnabled.asDriver(), result: result.asSignal(onErrorJustReturn: ""))
    }
}
