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

    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var repwTextField: UITextField!
    @IBOutlet weak var resetBtn: UIButton!

    var email = String()
    var authCode = String()

    private let viewModel = NewPwViewModel()

    private let errorLabel = UILabel()
    private let pwErrorLabel = UILabel()
    private let repwErrorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        bindViewModel()
        // Do any additional setup after loading the view.
    }

    func setUpUI() {
        resetBtn.rx.tap.subscribe(onNext: {
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
        let input = NewPwViewModel.input(
            userEmail: Driver.just(email),
            userCode: Driver.just(authCode),
            userPw: pwTextField.rx.text.orEmpty.asDriver(),
            userRepw: repwTextField.rx.text.orEmpty.asDriver(),
            doneTap: resetBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(resetBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: { _ in
            self.setButton(self.resetBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: {
            self.setUpErrorMessage(self.errorLabel, title: $0, superTextField: self.pwTextField)
        }, onCompleted: {
            self.nextScene(identifier: "main")
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
