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

    private var gradientLayer: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()

        splashImage.image = UIImage(named: "SplashImg")
        circleView.layer.cornerRadius = 30
        LoginBtn.backgroundColor = .cyan

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.LoginBtn.bounds
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        LoginBtn.layer.insertSublayer(gradientLayer, at: 0)
        LoginBtn.layer.cornerRadius = 20

        let bar: UINavigationBar! = self.navigationController?.navigationBar
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear

    }

    private func setUpUI() {
        LoginBtn.rx.tap.asObservable().subscribe(onNext: {
            guard let signInVC = self.storyboard?.instantiateViewController(identifier: "signInVC") else { return }
            self.navigationController?.pushViewController(signInVC, animated: true)
        }).disposed(by: rx.disposeBag)

        SignBtn.rx.tap.asObservable().subscribe(onNext: {
            guard let signUpVC = self.storyboard?.instantiateViewController(identifier: "signUpVC") else { return }
            self.navigationController?.pushViewController(signUpVC, animated: true)
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
