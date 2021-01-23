//
//  SplashViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SplashViewController: UIViewController {

    @IBOutlet weak var splashImage: UIImageView!
    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var SignBtn: UIButton!
    @IBOutlet weak var circleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        addGradient(LoginBtn)

        splashImage.image = UIImage(named: "SplashImg")
        circleView.layer.cornerRadius = 30

        let bar: UINavigationBar! = self.navigationController?.navigationBar
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
    }

    func setupUI() {
        loginBtn.rx.tap.asObservable().subscribe(onNext: {
            self.pushVC(identifier: "signInVC")
        }).disposed(by: rx.disposeBag)

        SignBtn.rx.tap.asObservable().subscribe(onNext: {
            self.pushVC(identifier: "signUpVC")
        }).disposed(by: rx.disposeBag)
    }
}
