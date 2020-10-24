//
//  PostViewModel.swift
//  Yally
//
//  Created by 이가영 on 2020/10/19.
//

import Foundation
import RxSwift
import RxCocoa

protocol recordViewControllerDelegate: class {
    func finishRecording(_ recordVC: PostViewController)
}

class PostViewModel: ViewModelType {

    private let disposeBag = DisposeBag()

    struct input {
        let selectRec: Driver<Void>
        let postText: Driver<String>
        let selectFile: Driver<Void>
        let selectCover: Driver<Void>
        let hashtag: Driver<[String]>
        let doneTap: Driver<Void>
    }

    struct output {
        let isEnable: Driver<Bool>
        let result: Signal<String>
        let timeFlow: Driver<String>
    }

    func transform(_ input: PostViewModel.input) -> PostViewModel.output {
        let api = TimeLineAPI()
        let info = Driver.combineLatest(input.postText, input.selectFile, input.selectCover, input.hashtag)
        let isEnable = info.map {
            YallyFilter.checkEmpty($0.0)
        }
        let result = PublishSubject<String>()
        let timeFlow = PublishSubject<String>()
        
        //info에 하나만 있어서그럼
        input.doneTap.withLatestFrom(info).asObservable().subscribe(onNext: {
            _, _, _, _ in

        }).disposed(by: disposeBag)
        
        input.selectRec.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            let driver = Driver<Int>.interval(.seconds(1)).map { _ in
                return 1
            }
            
        }).disposed(by: disposeBag)
        
        return output(isEnable: isEnable.asDriver(), result: result.asSignal(onErrorJustReturn: "포스팅 실패"), timeFlow: timeFlow.asDriver(onErrorJustReturn: ""))
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
