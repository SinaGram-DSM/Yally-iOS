//
//  Extension.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit
import RxCocoa
import RxSwift

extension UIColor {
    func hexUIColor(hex: String) -> UIColor {
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: CGFloat(1.0)
        )
    }
}

extension UIViewController {
    func nextScene(identifier: String) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(viewController!, animated: true)
    }

    func setButton(_ button: UIButton) {
        var gradientLayer: CAGradientLayer!

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = [UIColor().hexUIColor(hex: "4776e6").cgColor, UIColor().hexUIColor(hex: "8e54e9").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 20

        button.layer.insertSublayer(gradientLayer, at: 0)
        button.layer.cornerRadius = 20
        button.tintColor = .white
    }

    func defuatlBtn(_ button: UIButton) {
        button.backgroundColor = .gray
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.isEnabled = false
    }

    func setUpErrorMessage(_ sender: UILabel, title: String, superTextField: UITextField) {
        sender.translatesAutoresizingMaskIntoConstraints = false
        sender.text = title
        sender.textColor = .red
        sender.isHidden = false
        sender.font = UIFont.systemFont(ofSize: CGFloat(9))

        view.addSubview(sender)

        NSLayoutConstraint.activate([
            sender.topAnchor.constraint(equalTo: superTextField.bottomAnchor),
            sender.leadingAnchor.constraint(equalTo: superTextField.leadingAnchor)
        ])
    }

    func setUpErrorHidden(_ sender: UILabel) {
        sender.isHidden = true
    }
}

struct YallyFilter {
    static func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    static func checkPw(_ pw: String) -> Bool {
        let pwRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$"
        let pwTest = NSPredicate(format: "SELF MATCHES %@", pwRegEx)
        return pwTest.evaluate(with: pw)
    }

    static func checkEmpty(_ text: String) -> Bool {
        if text.isEmpty {
            return false
        } else {
            return true
        }
    }

    static func checkPwSignin(_ pw: String) -> Bool {
        if pw.count > 8 {
            return true
        } else {
            return false
        }
    }

}
