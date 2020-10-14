//
//  ProfileViewController.swift
//  Yally
//
//  Created by 문지수 on 2020/10/03.
//

import UIKit

import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listeningBtn: UIButton!
    @IBOutlet weak var listeningValue: UILabel!
    @IBOutlet weak var listenerBtn: UIButton!
    @IBOutlet weak var listenerValue: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //self.profileImage.layer.cornerRadius = 20
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true

    }

    func listeningValue(_ listening: Int) {

    }

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: alpha)
    }
}


