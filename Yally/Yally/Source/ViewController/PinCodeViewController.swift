//
//  PinCodeViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit
import SGCodeTextField
import RxSwift
import RxCocoa
import NSObject_Rx

class PinCodeViewController: UIViewController {

    @IBOutlet weak var pinCodeView: SGCodeTextField!
    @IBOutlet weak var nextBtn: UIButton!

    var email = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        setButton(nextBtn)
        bindViewModel()
    }

    func bindViewModel() {
        self.pinCodeView.textChangeHandler = { [self] (text, completed) in
            guard let authtext = text else { return }
            let api = AuthAPI()

            self.nextBtn.isSelected = completed
            self.nextBtn.isEnabled = completed

            self.nextBtn.rx.tap.asObservable().subscribe(onNext: {
                print(authtext)
                api.postConfirmCode(email, authtext)
                self.nextScene(identifier: "inputUser")
            }).disposed(by: rx.disposeBag)
        }
    }
}
