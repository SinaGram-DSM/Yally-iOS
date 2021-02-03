//
//  DetailViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/11/01.
//

import Foundation
import RxCocoa
import RxSwift

final class DetailViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    static let detailComment = PublishRelay<[Comment]>()
    static let detailData = PublishRelay<[DetailModel]>()

    struct input {
        let loadDetail: Signal<Void>
        let selectIndexPath: String
        let selectYally: Signal<Int>
        let deletePost: Signal<Void>
        let deleteCommnet: Signal<Int>
        let commentContent: Driver<String>
        let commentRecord: Driver<URL?>
        let commentTap: Driver<Void>
    }

    struct output {
        let result: Signal<String>
        let postYally: Signal<String>
        let deleteYally: Signal<String>
        let postComment: Signal<String>
        let deleteComment: Signal<String>
        let deletePost: Signal<String>
    }

    func transform(_ input: input) -> output {
        let api = TimeLineAPI()
        let result = PublishSubject<String>()
        let info = Signal.combineLatest(input.selectYally, DetailViewModel.detailData.asSignal()).asObservable()
        let deleteComInfo = Signal.combineLatest(input.deleteCommnet, DetailViewModel.detailComment.asSignal())
        let postInfo = Driver.combineLatest(input.commentContent, input.commentRecord)

        let yallyPost = PublishSubject<String>()
        let yallyDelete = PublishSubject<String>()
        let postComment = PublishSubject<String>()
        let deleteComment = PublishSubject<String>()
        let deletePost = PublishSubject<String>()

        input.loadDetail.asObservable().subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            api.postDetailPost(input.selectIndexPath).subscribe(onNext: { response, statusCode in
                switch statusCode {
                case .ok:
                    DetailViewModel.detailData.accept([response!])
                default:
                    result.onNext("자세히보기를 불러올 수 없음")
                }
            }).disposed(by: self.disposeBag)

            api.postDetailComment(input.selectIndexPath).subscribe(onNext: { response, statusCode in
                print(statusCode)
                switch statusCode {
                case .ok:
                    response?.comments.reverse()
                    DetailViewModel.detailComment.accept(response!.comments)
                default:
                    result.onNext("댓글을 불러올 수 없음")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.deletePost.asObservable().subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            api.deletePost(input.selectIndexPath).subscribe(onNext: { response in
                switch response {
                case .ok:
                    deletePost.onNext("")
                default:
                    deletePost.onNext("삭제할 수 있는 포스트가 없음")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.selectYally.asObservable().withLatestFrom(info).subscribe(onNext: {[weak self] row, data in
            guard let self = self else { return }
            if !data[row].isYally {
                api.postYally(input.selectIndexPath).subscribe(onNext: { response in
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
                api.deleteYally(input.selectIndexPath).subscribe(onNext: { response in
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

        input.deleteCommnet.asObservable().withLatestFrom(deleteComInfo).subscribe(onNext: {[weak self] (row, data) in
            guard let self = self else { return }
            let delete = data[row].id
            api.deleteComment(delete).subscribe(onNext: { response in
                switch response {
                case .ok:
                    deleteComment.onNext("")
                default:
                    deleteComment.onNext("댓글 삭제 취소")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.commentTap.asObservable().withLatestFrom(postInfo).subscribe(onNext: { content, record in
            api.postComment(.postComment(input.selectIndexPath), record, content).responseJSON { (response) in
                switch response.response?.statusCode {
                case 201:
                    postComment.onCompleted()
                case 404:
                    postComment.onNext("댓글을 작성할 글을 찾지 못함")
                default:
                    postComment.onNext("알 수 없는 오류")
                }
            }
        }).disposed(by: disposeBag)

        return output(
            result: result.asSignal(onErrorJustReturn: ""),
            postYally: yallyPost.asSignal(onErrorJustReturn: ""),
            deleteYally: yallyDelete.asSignal(onErrorJustReturn: ""),
            postComment: postComment.asSignal(onErrorJustReturn: ""),
            deleteComment: deleteComment.asSignal(onErrorJustReturn: ""),
            deletePost: deletePost.asSignal(onErrorJustReturn: ""))
    }
}
