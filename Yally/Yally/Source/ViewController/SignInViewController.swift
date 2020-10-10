//
//  SignInViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import UIKit
import RxCocoa
import RxSwift

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var forgotPwBtn: UIButton!

    private let viewModel = SignInViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    func setUpUI() {
        signInBtn.rx.tap.subscribe(onNext: {
            if YallyFilter.checkEmpty(self.emailTextField.text!) {

            }
        }).disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = SignInViewModel.input(userEmail: emailTextField.rx.text.orEmpty.asDriver(),
                                          userPw: pwTextField.rx.text.orEmpty.asDriver(),
                                          signInTap: signInBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(signInBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {_ in
            self.setButton(self.signInBtn)
        }).disposed(by: rx.disposeBag)
    }
}
