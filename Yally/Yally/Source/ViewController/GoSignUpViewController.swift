//
//  GoSignUpViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/04.
//

import UIKit
import TextFieldEffects

class GoSignUpViewController: UIViewController {

    @IBOutlet weak var SignUpBtn: UIButton!
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var ageTextField: HoshiTextField!
    @IBOutlet weak var pwTextField: HoshiTextField!
    @IBOutlet weak var repwTextField: HoshiTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setButton(SignUpBtn)
        // Do any additional setup after loading the view.
    }
}
