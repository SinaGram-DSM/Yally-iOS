//
//  SignInViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/02.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx
import TextFieldEffects

class SignInViewController: UIViewController {

    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var pwTextField: UITextField!
    @IBOutlet weak private var signInBtn: UIButton!
    @IBOutlet weak private var forgotPwBtn: UIButton!

    private let viewModel = SignInViewModel()
    private let errorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "로그인"

        emailTextField.clearButtonMode = .whileEditing
        pwTextField.clearButtonMode = .whileEditing
        bindViewModel()

        forgotPwBtn.rx.tap.subscribe(onNext: {
            self.pushVC(identifier: "Reset")
        }).disposed(by: rx.disposeBag)
    }

    private func bindViewModel() {
        let input = SignInViewModel.input(userEmail: emailTextField.rx.text.orEmpty.asDriver(),
                                          userPw: pwTextField.rx.text.orEmpty.asDriver(),
                                          doneTap: signInBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(signInBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in
            self.addGradient(self.signInBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(
                onNext: {[unowned self] message in self.textFieldErrorMessage(self.errorLabel, title: message, superTextField: self.pwTextField)},
                onCompleted: { [unowned self] in pushVC(identifier: "main")
            }).disposed(by: rx.disposeBag)
    }
}
