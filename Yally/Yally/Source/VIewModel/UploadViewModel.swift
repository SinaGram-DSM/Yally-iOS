//
//  UploadViewMOdel.swift
//  Yally
//
//  Created by 이가영 on 2020/11/28.
//

import Foundation
import RxSwift
import RxCocoa

final class UploadViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let selectIndexPath: String
        let postText: Driver<String>
        let selectFile: Driver<URL?>
        let selectCover: Driver<Data?>
        let doneTap: Driver<Void>
    }

    struct output {
        let result: Signal<String>
        let isEnable: Driver<Bool>
    }

    func transform(_ input: input) -> output {
        let api = TimeLineAPI()
        let hashtag = input.postText.map { $0.getHashtags() }
        let info = Driver.combineLatest(input.postText, input.selectFile, input.selectCover, hashtag)
        let result = PublishSubject<String>()
        let isEnable = info.map { !$0.0.isEmpty}

        input.doneTap.asObservable().withLatestFrom(info).subscribe(onNext: { content, sound, img, hashtag in
            api.uploadFormData(.updatePost(id: input.selectIndexPath), param: ["content": content, "hashtag": hashtag ?? ""], sound!, img)
                .responseJSON { (response) in
                    switch response.response?.statusCode {
                    case 201:
                        print("post success")
                        result.onCompleted()
                    default:
                        print("post fault")
                    }
                }
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: "포스팅 실패"), isEnable: isEnable.asDriver())
    }
}
