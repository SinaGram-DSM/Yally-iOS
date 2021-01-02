//
//  ProfileViewModel.swift
//  Yally
//
//  Created by 문지수 on 2020/11/07.
//
import Foundation

import RxSwift
import RxCocoa
import RxAlamofire

class ProfileViewModel: ViewModelType {

    private let disposeBag = DisposeBag()
    static var loadData = PublishRelay<ProfileModel>()
    

    struct input {
        let loadData: Signal<Void>
    }
    struct output {
        let result: Signal<String>

    }

    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let isEnabled = PublishSubject<String>()
        let result = PublishSubject<String>()
        
        input.loadData.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            api.getProfileValue("admin123@gmail.com").subscribe(onNext: { (response, statusCode) in
                switch statusCode {
                case .ok:
                    ProfileViewModel.loadData.accept(response!)
                    result.onCompleted()
                case .noHere:
                    result.onNext("페이지 로드 실패")
                default:
                    print("Default")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: "실패"))

    }
}
