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

    private let viewModel = CodeViewModel()
    let placeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        defuatlBtn(nextBtn)
        bindViewModel()
        setUpUI()
    }

    func setUpUI() {
        emailTextField.rx.text.orEmpty.asObservable()
            .map { YallyFilter.checkEmail($0) }
            .subscribe { [self] e in
                if !e.element! {
                    self.setUpErrorMessage(placeLabel, title: "이메일 형식이 맞지 않습니다.", superTextField: self.emailTextField)
                }
            }.disposed(by: rx.disposeBag)

        nextBtn.rx.tap.bind { [weak self] in
            self?.nextScene(identifier: "pinCode")
        }.disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = CodeViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
                                        doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {_ in
            self.placeLabel.isHidden = true
            self.setButton(self.nextBtn)
        }).disposed(by: rx.disposeBag)
    }

}
