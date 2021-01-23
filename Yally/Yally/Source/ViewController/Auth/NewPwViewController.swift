//
//  NewPwViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class NewPwViewController: UIViewController {

    @IBOutlet weak private var pwTextField: UITextField!
    @IBOutlet weak private var repwTextField: UITextField!
    @IBOutlet weak private var resetBtn: UIButton!

    var email = String()
    var authCode = String()

    private let viewModel = NewPwViewModel()

    private let errorLabel = UILabel()
    private let pwErrorLabel = UILabel()
    private let repwErrorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "로그인"

        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        resetBtn.rx.tap.subscribe(onNext: {
            if !YallyFilter.checkPw(self.pwTextField.text!) {
                self.textFieldErrorMessage(self.pwErrorLabel, title: "비밀번호 형식이 맞지 않습니다.", superTextField: self.pwTextField)
            } else {
                self.errorMessageHidden(self.pwErrorLabel)
            }
            if self.pwTextField.text! != self.repwTextField.text! {
                self.textFieldErrorMessage(self.repwErrorLabel, title: "비밀번호가 일치하지 않습니다.", superTextField: self.repwTextField)
            } else {
                self.errorMessageHidden(self.repwErrorLabel)
            }
        }).disposed(by: rx.disposeBag)
    }

    private func bindViewModel() {
        let input = NewPwViewModel.input(
            userEmail: Driver.just(email),
            userCode: Driver.just(authCode),
            userPw: pwTextField.rx.text.orEmpty.asDriver(),
            userRepw: repwTextField.rx.text.orEmpty.asDriver(),
            doneTap: resetBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(resetBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in
            self.addGradient(self.resetBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: { [unowned self] in
            self.textFieldErrorMessage(self.errorLabel, title: $0, superTextField: self.pwTextField)
        }, onCompleted: {
            self.pushVC(identifier: "main")
        }).disposed(by: rx.disposeBag)
    }

}
