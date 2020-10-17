//
//  PwCodeViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit
import SGCodeTextField

class PwCodeViewController: UIViewController {

    @IBOutlet weak var pinCode: SGCodeTextField!
    @IBOutlet weak var nextBtn: UIButton!

    var email = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.SGCodeTextFieldError(pinCode.text!, pinCode)
        setUpUI()
        bindViewModel()
    }

    func setUpUI() {
        pinCode.digitBackgroundColor = #colorLiteral(red: 0.7398572564, green: 0.609362185, blue: 0.9509858489, alpha: 1)
        pinCode.digitBorderColor = .clear
        pinCode.digitBorderColorEmpty = .clear
    }

    func bindViewModel() {
        self.pinCode.textChangeHandler = { [self] (text, completed) in
            self.nextBtn.isSelected = completed
            self.nextBtn.isEnabled = completed
            nextWithData()
        }
    }

    func nextWithData() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "newPw") as? NewPwViewController else { return }
        vc.email = email
        vc.authCode = pinCode.text!
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
