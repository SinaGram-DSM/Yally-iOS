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
    static let loadMoreData = PublishRelay<[MainModel]>()

    struct input {
        let loadData: Signal<Void>
        let loadMoreData: Signal<Void>
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
                case .unauthorized:
                    result.onNext("페이지가 없습니다.")
                default:
                    result.onNext("타임라인을 불러올 수 없습니다.")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.loadMoreData.asObservable().subscribe(onNext: { _ in
            api.getTimeLine().subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    MainViewModel.loadData.accept(response!.posts)
                case .unauthorized:
                    result.onNext("스크롤을 할 수 없습니다.")
                default:
                    result.onNext("무한 스크롤을 할 수 없습니다.")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: "타임라인 불러오기 실패"), data: MainViewModel.loadData.asDriver(onErrorJustReturn: []) )
    }
}
