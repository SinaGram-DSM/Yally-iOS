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
    static var loadMoreData = PublishRelay<[MainModel]>()

    struct input {
        let loadData: Signal<Void>
        let loadMoreData: Signal<Int>
        let selectCell: Signal<IndexPath>
        let selectIndexPath: Signal<Int>
        let selectDelete: Signal<Int>
    }

    struct output {
        let result: Signal<String>
        let yallyPost: Driver<String>
        let yallyDelete: Driver<String>
        let deletePost: Driver<String>
        let data: Driver<[MainModel]>
        let nextView: Signal<String>
    }

    func transform(_ input: input) -> output {
        let api = TimeLineAPI()
        let result = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectIndexPath, MainViewModel.loadData.asSignal()).asObservable()
        let detailInfo = Signal.combineLatest(input.selectCell, MainViewModel.loadData.asSignal()).asObservable()

        let yallyPost = PublishSubject<String>()
        let yallyDelete = PublishSubject<String>()
        let deletePost = PublishSubject<String>()

        let nextView = PublishSubject<String>()
        var selectIdx = String()

        input.loadData.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            api.getTimeLine(1).subscribe(onNext: { response, statusCode in
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

        input.loadMoreData.asObservable().subscribe(onNext: { page in
            api.getTimeLine(page).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    MainViewModel.loadMoreData.accept(response!.posts)
                    MainViewModel.loadMoreData.subscribe(onNext: { da in
                        let result = response?.posts
                        var dad = da
                        dad.append(contentsOf: result!)
                        MainViewModel.loadData.accept(dad)
                    }).disposed(by: self.disposeBag)
                case .unauthorized:
                    print("ASDfas")
                default:
                    print("Sdagreg")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.selectIndexPath.asObservable().withLatestFrom(info).subscribe(onNext: { row, data in
            let loadSet = data[row].id
            if !data[row].isYally {
                api.postYally(loadSet).subscribe(onNext: { response in
                    switch response {
                     case .ok:
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
                    case .noHere:
                        yallyDelete.onNext("게시물이 존재하지 않음")
                    default:
                        yallyDelete.onNext("Yally 실패")
                    }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)

        input.selectCell.asObservable().withLatestFrom(detailInfo).subscribe(onNext: { indexPath, data in
            selectIdx = data[indexPath.row].id
            nextView.onNext(selectIdx)
        }).disposed(by: disposeBag)

        input.selectDelete.asObservable().withLatestFrom(info).subscribe(onNext: { row, data in
            let deleteId = data[row].id
            api.deletePost(deleteId).subscribe(onNext: { response in
                switch response {
                 case .ok:
                    print("onCompleted")
                    deletePost.onCompleted()
                default:
                    deletePost.onNext("Yally 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(
            result: result.asSignal(onErrorJustReturn: "타임라인 불러오기 실패"),
            yallyPost: yallyPost.asDriver(onErrorJustReturn: "얄리 post 실패"),
            yallyDelete: yallyDelete.asDriver(onErrorJustReturn: "얄리 delete 실패"),
            deletePost: deletePost.asDriver(onErrorJustReturn: "글 삭제 실패"),
            data: MainViewModel.loadData.asDriver(onErrorJustReturn: []),
            nextView: nextView.asSignal(onErrorJustReturn: "디테일 포스트 실패"))
        }
}
