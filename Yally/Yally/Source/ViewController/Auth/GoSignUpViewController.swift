//
//  GoSignUpViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/15.
//

import UIKit
import RxSwift
import RxCocoa

final class GoSignUpViewController: UIViewController {

    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var ageTextField: UITextField!
    @IBOutlet weak private var pwTextField: UITextField!
    @IBOutlet weak private var repwTextField: UITextField!
    @IBOutlet weak private var signUpBtn: UIButton!

    var email = String()

    private let viewModel = SignUpViewModel()
    private let nameErrorLabel = UILabel()
    private let pwErrorLabel = UILabel()
    private let repwErrorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "회원가입"

        self.addGradient(signUpBtn)
        signUpBtn.isEnabled = false

        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        signUpBtn.rx.tap.subscribe(onNext: { [unowned self] _ in
            if !YallyFilter.checkPw(pwTextField.text!) {
                textFieldErrorMessage(pwErrorLabel, title: "비밀번호 형식이 맞지 않습니다.", superTextField: pwTextField)
            } else {
                errorMessageHidden(pwErrorLabel)
            }

            if pwTextField.text! != repwTextField.text! {
                textFieldErrorMessage(repwErrorLabel, title: "비밀번호가 일치하지 않습니다.", superTextField: repwTextField)
            } else {
                errorMessageHidden(repwErrorLabel)
            }
        }).disposed(by: rx.disposeBag)
    }

    private func bindViewModel() {
        let age = ageTextField.rx.text.orEmpty.asDriver()
        let input = SignUpViewModel.input(
            userEmail: Driver<String>.just(email),
            userName: nameTextField.rx.text.orEmpty.asDriver(),
            userAge: age.compactMap { Int($0) },
            userPw: pwTextField.rx.text.orEmpty.asDriver(),
            userRepw: repwTextField.rx.text.orEmpty.asDriver(),
            doneTap: signUpBtn.rx.tap.asSignal() )
        let output = viewModel.transform(input)

        output.isEnable.drive(signUpBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in
            addGradient(signUpBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: { [unowned self] in
            self.textFieldErrorMessage(nameErrorLabel, title: $0, superTextField: nameTextField)
        }, onCompleted: { [unowned self] in
            print("회원가입 성공")
            pushVC(identifier: "signInVC")
        }).disposed(by: rx.disposeBag)

    }

}
