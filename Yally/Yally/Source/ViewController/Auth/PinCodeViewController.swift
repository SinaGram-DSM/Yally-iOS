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

    @IBOutlet weak var pinCodeView: SGCodeTextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    var email = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.SGCodeTextFieldError(pinCodeView.text!, pinCodeView)
        setButton(nextBtn)
        bindViewModel()
        setUpUI()
    }

    func setUpUI() {
        pinCodeView.digitBackgroundColor = #colorLiteral(red: 0.7398572564, green: 0.609362185, blue: 0.9509858489, alpha: 1)
        pinCodeView.digitBorderColor = .clear
        pinCodeView.digitBorderColorEmpty = .clear
    }

    func bindViewModel() {
        self.pinCodeView.textChangeHandler = { [self] (text, completed) in
            guard let authtext = text else { return }
            let api = AuthAPI()

            self.nextBtn.isSelected = completed
            self.nextBtn.isEnabled = completed

            self.nextBtn.rx.tap.asObservable().subscribe(onNext: {
                    api.postConfirmCode(email, authtext).subscribe(onNext: { (response) in
                        switch response {
                        case .ok: nextWithData()
                        case .JWTdeadline: SGCodeTextFieldError("재설정 코드가 올바르지 않습니다.", pinCodeView)
                        default: SGCodeTextFieldError("인증 실패", pinCodeView)
                        }
                    }).disposed(by: rx.disposeBag)
            }).disposed(by: rx.disposeBag)
        }
    }

    func nextWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "inputUser") as? GoSignUpViewController else { return }
        vc.email = email
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
