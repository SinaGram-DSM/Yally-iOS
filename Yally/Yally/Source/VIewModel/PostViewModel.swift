//
//  PostViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import RxSwift
import RxCocoa

class PostViewModel: ViewModelType {

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
        let api = TimeLineAPI()
        let hashtag = input.postText.map { $0.getHashtags() }
        let info = Driver.combineLatest(input.postText, input.selectFile, input.selectCover, hashtag)
        let isEnable = info.map { !$0.0.isEmpty}
        let result = PublishSubject<String>()

        input.doneTap.asObservable().withLatestFrom(info).subscribe(onNext: { content, sound, img, hashtag in
            let httpClient = HTTPClient()
            httpClient.postFormData(.createPost, param: ["content": content, "hashtag": hashtag ?? ""], sound, img ?? nil).responseJSON { (response) in
                print(response.result)
                switch response.response?.statusCode {
                case 201:
                    print("post success")
                default:
                    print(response.response?.statusCode ?? "dd")
                    print("post fault")
                }
            }

//            api.createPost(sound, content, img, hashtag!).subscribe(onNext: { (response) in
//                switch response {
//                case .ok: result.onCompleted()
//                default: result.onNext("포스트 실패")
//                }
//            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "포스팅 실패"))
    }
}

//지울거임
struct YallyFilter {
    static func checkEmpty(_ text: String) -> Bool {
        if text.isEmpty {
            return false
        } else {
            return true
        }
    }
}
