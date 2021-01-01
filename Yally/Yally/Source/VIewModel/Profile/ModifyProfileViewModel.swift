//
//  ModifyProfileViewModel.swift
//  Yally
//
//  Created by 문지수 on 2020/12/13.
//

import Foundation

import RxSwift
import RxCocoa

class ModifyProfileViewModel: ViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct input {
        let nickName: Driver<String>
        let userImage: Driver<String>
        let doneTap: Signal<Void>
    }
    
    struct output {
        let result: Signal<String>
        let isEnabled: Driver<Bool>
    }
    
    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let result = PublishSubject<String>()
        let info = Driver.combineLatest(input.nickName, input.userImage)
        let isEnabled = info.map { !$0.0.isEmpty }
        
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: { nickName, image in
            api.putModifyProfile().subscribe(onNext: { (response, statusCode) in
                switch statusCode {
                case .success:
                    result.onCompleted()
                case .noHere:
                    result.onNext("변경실패")
                default:
                    result.onNext("default")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        return output(result: result.asSignal(onErrorJustReturn: ""), isEnabled: isEnabled.asDriver())
        
    }
}
