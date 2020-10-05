//
//  PinCodeViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit
import OTPInputView

class PinCodeViewController: UIViewController {

    @IBOutlet weak var pinCodeView: OTPInputView!
    @IBOutlet weak var nextBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        setButton(nextBtn)
    }

    func setUpUI() {
        nextBtn.rx.tap.asObservable().subscribe(onNext: {
            self.nextScene(identifier: "inputUser")
        }).disposed(by: rx.disposeBag)
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
