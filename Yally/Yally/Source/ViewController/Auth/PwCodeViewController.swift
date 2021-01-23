//
//  PwCodeViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit
import SGCodeTextField

class PwCodeViewController: UIViewController {

    @IBOutlet weak private var pinCode: SGCodeTextField!
    @IBOutlet weak private var nextBtn: UIButton!

    var email = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "로그인"

        addGradient(nextBtn)

        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        pinCode.digitBackgroundColor = #colorLiteral(red: 0.7398572564, green: 0.609362185, blue: 0.9509858489, alpha: 1)
        pinCode.digitBorderColor = .clear
        pinCode.digitBorderColorEmpty = .clear
    }

    private func bindViewModel() {
        self.pinCode.textChangeHandler = { [unowned self] (text, completed) in
            self.nextBtn.isSelected = completed
            self.nextBtn.isEnabled = completed
        }

        nextBtn.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.pushWithData()
        }).disposed(by: rx.disposeBag)
    }

    private func pushWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "newPw") as? NewPwViewController else { return }
        vc.email = email
        vc.authCode = pinCode.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
