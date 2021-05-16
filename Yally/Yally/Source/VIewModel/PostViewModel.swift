//
//  PostViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import RxSwift
import RxCocoa

final class PostViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let postText: Driver<String>
        let selectFile: Driver<URL>
        let selectCover: Driver<Data?>
        let doneTap: Driver<Void>
    }

    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
    }

    func transform(_ input: input) -> output {
        let hashtag = input.postText.map { $0.getHashtags() }
        let info = Driver.combineLatest(input.postText, input.selectFile, input.selectCover, hashtag)
        let isEnable = info.map { !$0.0.isEmpty }
        let result = PublishSubject<String>()
        let api = TimeLineAPI()

        input.doneTap.asObservable().withLatestFrom(info).subscribe(onNext: { content, sound, img, hashtag in
            api.postFormData(.createPost, param: ["content": content, "hashtag": hashtag ?? ""], sound, img ?? nil).responseJSON { (response) in
                switch response.response?.statusCode {
                case 201:
                    result.onCompleted()
                    print("post success")
                default:
                    print("post fault")
                }
            }
        }).disposed(by: disposeBag)

        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "포스팅 실패"))
    }
}
