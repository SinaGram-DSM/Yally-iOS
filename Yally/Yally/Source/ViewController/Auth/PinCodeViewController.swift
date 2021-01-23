//
//  PinCodeViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit
import SGCodeTextField
import RxSwift
import RxCocoa
import NSObject_Rx

class PinCodeViewController: UIViewController {

    @IBOutlet weak private var pinCodeView: SGCodeTextField!
    @IBOutlet weak private var nextBtn: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subTitleLabel: UILabel!

    var email = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "회원가입"

        self.pinCodeErrorMessage(pinCodeView.text!, pinCodeView)
        addGradient(nextBtn)
        bindViewModel()
        setupUI()
    }

    private func setupUI() {
        pinCodeView.digitBackgroundColor = #colorLiteral(red: 0.8624253869, green: 0.7955209613, blue: 1, alpha: 1)
        pinCodeView.digitBorderColor = .clear
        pinCodeView.digitBorderColorEmpty = .clear
    }

    private func bindViewModel() {
        self.pinCodeView.textChangeHandler = { [self] (text, completed) in
            self.nextBtn.isSelected = completed
            self.nextBtn.isEnabled = completed
        }

        self.nextBtn.rx.tap.asObservable().subscribe(onNext: { [unowned self] in
            let api = AuthAPI()
            api.postConfirmCode(code: email, userEmail: pinCodeView.text!).subscribe(onNext: { (response) in
                    switch response {
                    case .ok: self.pushWithData()
                    case .unauthorized: self.pinCodeErrorMessage("재설정 코드가 올바르지 않습니다.", pinCodeView)
                    default: self.pinCodeErrorMessage("인증 실패", pinCodeView)
                    }
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
    }

    private func pushWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "inputUser") as? GoSignUpViewController else { return }
        vc.email = email
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
