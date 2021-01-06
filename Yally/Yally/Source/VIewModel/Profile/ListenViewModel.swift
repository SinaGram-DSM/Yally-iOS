//
//  ListenViewModel.swift
//  Yally
//
//  Created by 문지수 on 2020/11/12.
//

import Foundation

import RxSwift
import RxCocoa

class ListenViewModel: ViewModelType {

    private let disposeBag = DisposeBag()
    static var loadData = PublishRelay<listen>()

    struct input {
        let loadData: Signal<Void>

    }
    struct output {
      //  let isEnabled: Driver<Bool>
        let result: Signal<String>
        let loadApplyList: PublishRelay<listen>

    }

    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let result = PublishSubject<String>()
        let loadApplyList = PublishRelay<listen>()

        input.loadData.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            api.getListenigList("admin123@gmail.com").subscribe(onNext: { (response, statuscode) in
                switch statuscode {
                case .ok:
                    if let response = response {
                        loadApplyList.accept(response)
                    }
                case .noHere: result.onNext("페이지 로드 실패")
                default:
                    print("Default")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.loadData.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            api.getListenerList("admin123@gmail.com").subscribe(onNext: { (response, statuscode) in
                switch statuscode {
                case .ok:
                    if let response = response {
                        loadApplyList.accept(response)
                    }
                case .noHere: result.onNext("페이지 로드 실패")
                default:
                    print("Default")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: "실패"), loadApplyList: loadApplyList)
    }

}
