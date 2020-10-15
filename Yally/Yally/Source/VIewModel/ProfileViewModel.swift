//
//  ProfileViewModel.swift
//  Yally
//
//  Created by 문지수 on 2020/10/03.
//

import Foundation

import RxSwift
import RxCocoa

class ProfileViewModel: ViewModelType {
    struct input {
        let loadData: Completable
    }
    struct output {
        let result: Signal<Void>
    }
    
    func transform(_ input: input) -> output {
        let api = ProfileAPI()
        let result = PublishSubject<String>()
        
        input.loadData.subscribe(){ [weak self] (_) in
            guard let self = self else { return }
            
            
        }
        
    }
}
