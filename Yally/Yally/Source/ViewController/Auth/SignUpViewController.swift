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

class SingUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    private let viewModel = CodeViewModel()
    private let placeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "회원가입"

        setupUI()
        bindViewModel()
    }

    func setupUI() {
        nextBtn.rx.tap
            .subscribe(onNext: {
                if YallyFilter.checkEmail(self.emailTextField.text!) {
                    self.errorMessageHidden(self.placeLabel)
                } else {
                    self.textFieldErrorMessage(self.placeLabel, title: "이메일 형식이 맞지 않습니다.", superTextField: self.emailTextField)
                }
            }).disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = CodeViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
                                        doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: { [unowned self] _ in
            self.addGradient(nextBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: { [unowned self] in
            self.textFieldErrorMessage(self.placeLabel, title: $0, superTextField: self.emailTextField)
        }, onCompleted: { [unowned self] in nextWithData()}).disposed(by: rx.disposeBag)
    }

    func nextWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "pinCode") as? PinCodeViewController else { return }
        vc.email = emailTextField.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
