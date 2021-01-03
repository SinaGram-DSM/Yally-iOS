//
//  ResetPwViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit

class ResetPwViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!

    private let viewModel = ResetViewModel()
    private let errorLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "로그인"

        setUpUI()
        bindViewModel()
        // Do any additional setup after loading the view.
    }

    func setUpUI() {
        nextBtn.rx.tap
            .subscribe(onNext: {
                if YallyFilter.checkEmail(self.emailTextField.text!) {
                    self.setUpErrorHidden(self.errorLabel)
                } else {
                    self.setUpErrorMessage(self.errorLabel, title: "이메일 형식이 맞지 않습니다.", superTextField: self.emailTextField)
                }
            }).disposed(by: rx.disposeBag)
    }

    func bindViewModel() {
        let input = ResetViewModel.input(email: emailTextField.rx.text.orEmpty.asDriver(),
            doneTap: nextBtn.rx.tap.asSignal())
        let output = viewModel.transform(input)

        output.isEnable.drive(nextBtn.rx.isEnabled).disposed(by: rx.disposeBag)
        output.isEnable.drive(onNext: {_ in
            self.setButton(self.nextBtn)
        }).disposed(by: rx.disposeBag)

        output.result.emit(onNext: {
            self.setUpErrorMessage(self.errorLabel, title: $0, superTextField: self.emailTextField)
        }, onCompleted: { [unowned self] in nextWithData()}).disposed(by: rx.disposeBag)
    }

    func nextWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PwPinCode") as? PwCodeViewController else { return }
        vc.email = emailTextField.text!
        self.navigationController?.pushViewController(vc, animated: true)
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
