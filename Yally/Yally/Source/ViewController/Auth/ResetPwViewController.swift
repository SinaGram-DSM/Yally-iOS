//
//  ResetPwViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit

final class ResetPwViewController: UIViewController {

    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var nextBtn: UIButton!

    private let viewModel = ResetViewModel()
    private let errorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "로그인"

        setupUI()
        bindViewModel()
        // Do any additional setup after loading the view.
    }

    private func setupUI() {
        nextBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                if YallyFilter.checkEmail(emailTextField.text!) {
                    errorMessageHidden(errorLabel)
                } else {
                    textFieldErrorMessage(errorLabel, title: "이메일 형식이 맞지 않습니다.", superTextField: emailTextField)
                }
            }).disposed(by: rx.disposeBag)
    }

    private func bindViewModel() {
        let input = ResetViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {[unowned self] _ in
            addGradient(nextBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: { [unowned self] in
            textFieldErrorMessage(errorLabel, title: $0, superTextField: emailTextField)
        }, onCompleted: { [unowned self] in pushWithData()}).disposed(by: rx.disposeBag)
    }

    private func pushWithData() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "PwPinCode") as? PwCodeViewController else { return }
        vc.email = emailTextField.text!
        navigationController?.pushViewController(vc, animated: true)
    }

}
