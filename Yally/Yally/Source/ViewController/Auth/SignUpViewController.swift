//
//  SingUpViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit
import TextFieldEffects
import RxCocoa
import RxSwift
import NSObject_Rx

final class SingUpViewController: UIViewController {

    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var nextBtn: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subTitleLabel: UILabel!

    private let viewModel = CodeViewModel()
    private let placeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "회원가입"

        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        nextBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                if YallyFilter.checkEmail(emailTextField.text!) {
                    errorMessageHidden(placeLabel)
                } else {
                    textFieldErrorMessage(placeLabel, title: "이메일 형식이 맞지 않습니다.", superTextField: emailTextField)
                }
            }).disposed(by: rx.disposeBag)
    }

    private func bindViewModel() {
        let input = CodeViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
                                        doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: { [unowned self] _ in
            addGradient(nextBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: { [unowned self] in
            textFieldErrorMessage(placeLabel, title: $0, superTextField: emailTextField)
        }, onCompleted: { [unowned self] in pushWithData()}).disposed(by: rx.disposeBag)
    }

    private func pushWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "pinCode") as? PinCodeViewController else { return }
        vc.email = emailTextField.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
