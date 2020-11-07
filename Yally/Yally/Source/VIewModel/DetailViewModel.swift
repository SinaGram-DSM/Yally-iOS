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
    }

    struct output {
        let result: Signal<String>
    }

    func transform(_ input: input) -> output {
        let api = TimeLineAPI()
        let result = PublishSubject<String>()

//        let info = Signal.combineLatest(input.selectIndexPath, detailData.asSignal()).asObservable()

        input.loadDetail.asObservable().subscribe(onNext: { _ in
            print(input.selectIndexPath)
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
                switch statusCode {
                case .ok:
                    DetailViewModel.detailComment.accept(response!.comments)
                default:
                    result.onNext("댓글을 불러올 수 없음")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: ""))
    }
}
