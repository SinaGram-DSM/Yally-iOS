//
//  MainViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let loadData: Signal<Void>
        let loadMoreData: Signal<Int>
        let selectCell: Signal<Int>
        let selectIndexPath: Signal<Int>
        let selectDelete: Signal<Int>
    }

    struct output {
        let result: Signal<String>
        let yallyPost: Driver<String>
        let yallyDelete: Driver<String>
        let deletePost: Driver<String>
        let nextView: Signal<String>
        let loadMoreData: BehaviorRelay<[MainModel]>
        let loadData: BehaviorRelay<[MainModel]>
    }

    func transform(_ input: input) -> output {
        let api = TimeLineAPI()
        let result = PublishSubject<String>()
        let loadMoreData = BehaviorRelay<[MainModel]>(value: [])
        let loadData = BehaviorRelay<[MainModel]>(value: [])
        var selectIdx = String()
        
        let yallyPost = PublishSubject<String>()
        let yallyDelete = PublishSubject<String>()
        let deletePost = PublishSubject<String>()
        let nextView = PublishSubject<String>()
        
        let info = Signal.combineLatest(input.selectIndexPath, loadData.asSignal(onErrorJustReturn: [])).asObservable()
        let detailInfo = Signal.combineLatest(input.selectCell, loadData.asSignal(onErrorJustReturn: [])).asObservable()
        let deleteInfo = Signal.combineLatest(input.selectDelete, loadData.asSignal(onErrorJustReturn: []))

        input.loadData.asObservable()
            .flatMap{ api.getTimeLine(1) }
            .subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadData.accept(response!.posts)
                    result.onCompleted()
                case .unauthorized:
                    result.onNext("페이지가 없습니다.")
                default:
                    result.onNext("타임라인을 불러올 수 없습니다.")
                }
            }).disposed(by: disposeBag)

        input.loadMoreData.asObservable()
            .flatMap{ api.getTimeLine($0) }
            .subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    loadMoreData.accept(response!.posts)
                case .unauthorized:
                    print("인증된 사용자가 아님")
                default:
                    print("더이상 불러올 타임라인이 없습니다.")
                }
            }).disposed(by: self.disposeBag)

        input.selectIndexPath.asObservable().withLatestFrom(info).subscribe(onNext: {[weak self] row, data in
            guard let self = self else { return }
            let loadSet = data[row].id
            if !data[row].isYally {
                api.postYally(loadSet).subscribe(onNext: { response in
                    switch response {
                     case .ok:
                        yallyPost.onNext("keep")
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
                        yallyDelete.onNext("keep")
                    case .noHere:
                        yallyDelete.onNext("게시물이 존재하지 않음")
                    default:
                        yallyDelete.onNext("Yally 실패")
                    }
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)

        input.selectCell.asObservable().withLatestFrom(detailInfo).subscribe(onNext: { indexPath, data in
            selectIdx = data[indexPath].id
            nextView.onNext(selectIdx)
        }).disposed(by: disposeBag)

        input.selectDelete.asObservable().withLatestFrom(deleteInfo).subscribe(onNext: {[weak self] row, data in
            guard let self = self else { return }
            let deleteId = data[row].id
            api.deletePost(deleteId).subscribe(onNext: { response in
                switch response {
                 case .ok:
                    deletePost.onNext("")
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
            nextView: nextView.asSignal(onErrorJustReturn: "디테일 포스트 실패"),
            loadMoreData: loadMoreData,
            loadData: loadData)
        }
}

//Extension 파일로 합칠 것들
extension BehaviorRelay where Element: RangeReplaceableCollection {
    func add(element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }

    func insert(element: Element.Element) {
        var array = self.value
        array.insert(element, at: 0 as! Element.Index)
        self.accept(array)
    }
}
