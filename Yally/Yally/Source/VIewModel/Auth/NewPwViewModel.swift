//
//  NewPwViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import Foundation
import RxSwift
import RxCocoa

class NewPwViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let userEmail: Driver<String>
        let userCode: Driver<String>
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
        let info = Driver.combineLatest(input.userEmail, input.userCode, input.userRepw)
        let isEnable = info.map { YallyFilter.checkEmpty($0.2)
        }
        let result = PublishSubject<String>()

        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { userE, userC, userR in
            api.putNewPw(userE, userC, userR).subscribe(onNext: { response in
                switch response {
                case .ok: result.onCompleted()
                case .overlap: result.onNext("인증코드가 이상합니다.")
                default: result.onNext("비밀번호 재설정 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "비밀번호 재설정 실패"))
    }
}
