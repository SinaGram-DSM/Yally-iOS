//
//  DetailViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/11/01.
//

import Foundation
import RxCocoa
import RxSwift

class DetailViewModel: ViewModelType {
    private let disposeBag = DisposeBag()

    static let detailComment = PublishRelay<[Comment]>()
    static let detailData = PublishRelay<[DetailModel]>()

    struct input {
        let loadDetail: Signal<Void>
        let selectIndexPath: String
        let selectYally: Signal<Int>
        let deletePost: Signal<Int>
        let deleteCommnet: Signal<Int>
    }

    struct output {
        let result: Signal<String>
    }

    func transform(_ input: input) -> output {
        let api = TimeLineAPI()
        let result = PublishSubject<String>()
        let deletePost = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectYally, DetailViewModel.detailData.asSignal()).asObservable()
        let commentInfo = Signal.combineLatest(input.selectYally, DetailViewModel.detailComment.asSignal())
        let yallyPost = PublishSubject<String>()
        let yallyDelete = PublishSubject<String>()

        input.loadDetail.asObservable().subscribe(onNext: { _ in
            api.postDetailPost(input.selectIndexPath).subscribe(onNext: { response, statusCode in
                print(statusCode)
                switch statusCode {
                case .ok:
                    var model = [DetailModel]()
                    model.append(response!)
                    DetailViewModel.detailData.accept(model)
                    model.removeAll()
                default:
                    result.onNext("자세히보기를 불러올 수 없음")
                }
            }).disposed(by: self.disposeBag)

            api.postDetailComment(input.selectIndexPath).subscribe(onNext: { response, statusCode in
                print(statusCode)
                switch statusCode {
                case .ok:
                    DetailViewModel.detailComment.accept(response!.comments)
                    print(response?.comments)
                default:
                    result.onNext("댓글을 불러올 수 없음")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.selectYally.asObservable().withLatestFrom(info).subscribe(onNext: { _ in
            api.deletePost(input.selectIndexPath).subscribe(onNext: { statusCode in
                switch statusCode {
                case .ok:
                    deletePost.onCompleted()
                default:
                    deletePost.onNext("포스트 삭제 실패")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.selectYally.asObservable().withLatestFrom(info).subscribe(onNext: { row, data in
            if !data[row].isYally {
                api.postYally(input.selectIndexPath).subscribe(onNext: { response in
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
                api.deleteYally(input.selectIndexPath).subscribe(onNext: { response in
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

        input.selectYally.asObservable().withLatestFrom(commentInfo).subscribe(onNext: { (row, data) in
            let delete = data[row].id
            api.deleteComment(delete).subscribe(onNext: { response in
                switch response {
                case .ok:
                    print("ok")
                default:
                    print("ASdf")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        return output(result: result.asSignal(onErrorJustReturn: ""))
    }
}
