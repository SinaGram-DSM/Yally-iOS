//
//  SplashViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var splashImage: UIImageView!
    @IBOutlet weak var tapLoginBtn: UIButton!
    @IBOutlet weak var tapSignBtn: UIButton!
    @IBOutlet weak var circleView: UIView!

    private var gradientLayer: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        splashImage.image = UIImage(named: "SplashImg")
        circleView.layer.cornerRadius = 30
        tapLoginBtn.backgroundColor = .cyan
        tapLoginBtn.layer.cornerRadius = 20

//        self.gradientLayer = CAGradientLayer()
//        self.gradientLayer.frame = self.view.bounds
//        self.gradientLayer.colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
//        self.view.layer.addSublayer(self.gradientLayer)
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
