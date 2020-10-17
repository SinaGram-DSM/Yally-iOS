//
//  GoSignUpViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/15.
//

import UIKit
import RxSwift
import RxCocoa

class GoSignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var repwTextField: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!

    var email = String()

    private let viewModel = SignUpViewModel()
    private let nameErrorLabel = UILabel()
    private let pwErrorLabel = UILabel()
    private let repwErrorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        bindViewModel()
    }

    func setUpUI() {
        signUpBtn.rx.tap.subscribe(onNext: {
            if !YallyFilter.checkPw(self.pwTextField.text!) {
                self.setUpErrorMessage(self.pwErrorLabel, title: "비밀번호 형식이 맞지 않습니다.", superTextField: self.pwTextField)
            } else {
                self.setUpErrorHidden(self.pwErrorLabel)
            }

            if self.pwTextField.text! != self.repwTextField.text! {
                self.setUpErrorMessage(self.repwErrorLabel, title: "비밀번호가 일치하지 않습니다.", superTextField: self.repwTextField)
            } else {
                self.setUpErrorHidden(self.repwErrorLabel)
            }
        }).disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
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
        output.isEnable.drive(onNext: { _ in
            self.setButton(self.signUpBtn)
        }).disposed(by: rx.disposeBag)
        output.result.emit(onNext: {
            self.setUpErrorMessage(self.nameErrorLabel, title: $0, superTextField: self.nameTextField)
        }, onCompleted: {
            self.nextScene(identifier: "signInVC")
        }).disposed(by: rx.disposeBag)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
