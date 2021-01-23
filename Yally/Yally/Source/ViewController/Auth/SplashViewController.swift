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

    @IBOutlet weak private var splashImage: UIImageView!
    @IBOutlet weak private var loginBtn: UIButton!
    @IBOutlet weak private var SignBtn: UIButton!
    @IBOutlet weak private var circleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        addGradient(loginBtn)

        splashImage.image = UIImage(named: "SplashImg")
        circleView.layer.cornerRadius = 30

        let bar: UINavigationBar! = self.navigationController?.navigationBar
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
    }

    private func setupUI() {
        loginBtn.rx.tap.asObservable().subscribe(onNext: {
            self.pushVC(identifier: "signInVC")
        }).disposed(by: rx.disposeBag)

        SignBtn.rx.tap.asObservable().subscribe(onNext: {
            self.pushVC(identifier: "signUpVC")
        }).disposed(by: rx.disposeBag)
    }
}
