//
//  ResetPwViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit

class ResetPwViewController: UIViewController {

    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var nextBtn: UIButton!

    private let viewModel = ResetViewModel()
    private let errorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "로그인"

        setupUI()
        bindViewModel()
        // Do any additional setup after loading the view.
    }

    private func setupUI() {
        nextBtn.rx.tap
            .subscribe(onNext: {
                if YallyFilter.checkEmail(self.emailTextField.text!) {
                    self.errorMessageHidden(self.errorLabel)
                } else {
                    self.textFieldErrorMessage(self.errorLabel, title: "이메일 형식이 맞지 않습니다.", superTextField: self.emailTextField)
                }
            }).disposed(by: rx.disposeBag)
    }

    private func bindViewModel() {
        let input = ResetViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in
            self.addGradient(nextBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: { [unowned self] in
            self.textFieldErrorMessage(self.errorLabel, title: $0, superTextField: self.emailTextField)
        }, onCompleted: { [unowned self] in pushWithData()}).disposed(by: rx.disposeBag)
    }

    private func pushWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PwPinCode") as? PwCodeViewController else { return }
        vc.email = emailTextField.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
