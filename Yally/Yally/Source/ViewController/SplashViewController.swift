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

        setUpUI()
        setButton(LoginBtn)

        splashImage.image = UIImage(named: "SplashImg")
        circleView.layer.cornerRadius = 30

        let bar: UINavigationBar! = self.navigationController?.navigationBar
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear
    }

    private func setUpUI() {
        LoginBtn.rx.tap.asObservable().subscribe(onNext: {
            self.nextScene(identifier: "signInVC")
        }).disposed(by: rx.disposeBag)

        SignBtn.rx.tap.asObservable().subscribe(onNext: {
            self.nextScene(identifier: "signUpVC")
        }).disposed(by: rx.disposeBag)
    }
}
