//
//  MainViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/25.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel: ViewModelType {

    private let disposeBag = DisposeBag()
    static let loadData = PublishRelay<[MainModel]>()

    struct input {
        let loadData: Signal<Void>
    }

    struct output {
        let result: Signal<String>
        let data: Driver<[MainModel]>
    }

    func transform(_ input: MainViewModel.input) -> MainViewModel.output {
        let api = TimeLineAPI()
        let result = PublishSubject<String>()

        input.loadData.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            api.getTimeLine().subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
//                    var result = [MainModel]()
                    print(response as Any)
                    MainViewModel.loadData.accept(response!.posts)

                    print(MainViewModel.loadData)
                case .unauthorized:
                    result.onNext("페이지가 없습니다.")
                default:
                    result.onNext("타임라인을 불러올 수 없습니다.")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: "타임라인 불러오기 실패"), data: MainViewModel.loadData.asDriver(onErrorJustReturn: []) )
    }
}
