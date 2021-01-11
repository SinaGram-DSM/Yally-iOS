//
//  ProfileViewModel.swift
//  Yally
//
//  Created by 문지수 on 2020/11/07.
//
import Foundation

import RxSwift
import RxCocoa
import RxAlamofire

class ProfileViewModel: ViewModelType {

    private let disposeBag = DisposeBag()
    static var loadData = PublishRelay<ProfileModel>()
    static var LoadData = PublishRelay<posts>()

    struct input {
        let loadData: Signal<Void>
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
        let api = ProfileAPI()
        let isEnabled = PublishSubject<String>()
        let loadMoreData = BehaviorRelay<[MainModel]>(value: [])
        let loadData = BehaviorRelay<[MainModel]>(value: [])
        let yallyPost = PublishSubject<String>()
        let yallyDelete = PublishSubject<String>()
        let deletePost = PublishSubject<String>()
        let nextView = PublishSubject<String>()
        let result = PublishSubject<String>()

        input.loadData.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            api.getProfileValue("admin123@gmail.com").subscribe(onNext: { (response, statusCode) in
                switch statusCode {
                case .ok:
                    ProfileViewModel.loadData.accept(response!)
                    result.onCompleted()
                case .noHere:
                    result.onNext("페이지 로드 실패")
                default:
                     print("ㄲㄲ")
                }

            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        input.loadData.asObservable().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            api.getTimeLine("admin123@gmail.com", 1).subscribe(onNext: { (response, statusCode) in
                switch statusCode {
                case .ok:
                    ProfileViewModel.LoadData.accept(response!)
                    result.onCompleted()
                case .noHere:
                    result.onNext("패이지 로드 살패")
                default:
                    result.onNext("Default")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return output(result: result.asSignal(onErrorJustReturn: "실패"),
                      yallyPost: yallyPost.asDriver(onErrorJustReturn: "얄리 post 실패"),
                      yallyDelete: yallyDelete.asDriver(onErrorJustReturn: "얄리 delete 실패"),
                      deletePost: deletePost.asDriver(onErrorJustReturn: "글 삭제 실패"),
                      nextView: nextView.asSignal(onErrorJustReturn: "디테일 포스트 실패"),
                      loadMoreData: loadMoreData,
                      loadData: loadData)
    }
}

extension BehaviorRelay where Element: RangeReplaceableCollection {
    func add(element: Element.Element) {
        var array = self.value
        array.append(element)
        self.accept(array)
    }
}
