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
    static var loadData = PublishRelay<[MainModel]>()
    static let loadMoreData = PublishRelay<[MainModel]>()

    struct input {
        let loadData: Signal<Void>
        let loadMoreData: Signal<Void>
        let selectCell: Signal<IndexPath>
        let selectIndexPath: Signal<Int>

    }

    struct output {
        let result: Signal<String>
        let yallyPost: Signal<String>
        let yallyDelete: Signal<String>
        let data: Driver<[MainModel]>
        let nextView: Signal<String>
    }

    func transform(_ input: input) -> output {
        let api = TimeLineAPI()
        let result = PublishSubject<String>()
        let loadData = PublishRelay<[MainModel]>()
        let info = Signal.combineLatest(input.selectIndexPath, MainViewModel.loadData.asSignal()).asObservable()
        let yallyPost = PublishSubject<String>()
        let yallyDelete = PublishSubject<String>()
        var selectIdx = String()
        let nextView = PublishSubject<String>()

        input.loadData.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            api.getTimeLine().subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    MainViewModel.loadData.accept(response!.posts)
                    print(response?.posts)
                    result.onCompleted()
                case .unauthorized:
                    result.onNext("페이지가 없습니다.")
                default:
                    result.onNext("타임라인을 불러올 수 없습니다.")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

//        input.loadMoreData.asObservable().subscribe(onNext: { _ in
//            api.getTimeLine().subscribe(onNext: { response, statusCode in
//                switch statusCode {
//                case .ok:
//                    MainViewModel.loadData.accept(response!.posts)
//                case .unauthorized:
//                    result.onNext("스크롤을 할 수 없습니다.")
//                default:
//                    result.onNext("무한 스크롤을 할 수 없습니다.")
//                }
//            }).disposed(by: self.disposeBag)
//        }).disposed(by: disposeBag)

        input.selectIndexPath.asObservable().withLatestFrom(info).subscribe(onNext: { row, data in
            let loadSet = data[row].id
            print("loaSet \(loadSet)")
            if !data[row].isYally {
                api.postYally(loadSet).subscribe(onNext: { response in
                    switch response {
                     case .ok:
                        print("onCompleted")
                        yallyPost.onCompleted()
                    case .noHere:
                        yallyPost.onNext("게시물이 존재하지 않음")
                    default:
                        yallyPost.onNext("Yally 실패")
                    }
                }).disposed(by: self.disposeBag)
            } else {
                api.deleteYally(loadSet).subscribe(onNext: { response in
                    switch response {
                    case .ok:
                        yallyDelete.onCompleted()
                        data[row].isYally
                    case .noHere:
                        yallyDelete.onNext("게시물이 존재하지 않음")
                    default:
                        yallyDelete.onNext("Yally 실패")
                    }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)

        input.selectCell.asObservable().withLatestFrom(info).subscribe(onNext: { indexPath, data in
            selectIdx = data[indexPath].id
            nextView.onNext(selectIdx)
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: "타임라인 불러오기 실패"), yallyPost: yallyPost.asSignal(onErrorJustReturn: "얄리 post 실패"), yallyDelete: yallyDelete.asSignal(onErrorJustReturn: "얄리 delete 실패"), data: MainViewModel.loadData.asDriver(onErrorJustReturn: []), nextView: nextView.asSignal(onErrorJustReturn: "디테일 포스트 실패"))
    }
}
