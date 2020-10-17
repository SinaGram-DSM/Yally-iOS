//
//  Extension.swift
//  Yally
//
//  Created by 이가영 on 2020/10/03.
//

import UIKit
import RxCocoa
import RxSwift
import SGCodeTextField

extension UIColor {

    convenience init(rgb: String) {
        var rgbValue: UInt64 = 0
        Scanner(string: rgb).scanHexInt64(&rgbValue)
        self.init(
                    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                    blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                    alpha: CGFloat(1.0)
                )
      }

}

extension UIViewController {
    func pushVC(identifier: String) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(viewController!, animated: true)
    }

    func addGradient(_ button: UIButton) {
        var gradientLayer: CAGradientLayer!

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = [UIColor(rgb: "4776e6").cgColor, UIColor(rgb: "8e54e9").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 20

        button.layer.insertSublayer(gradientLayer, at: 0)
        button.layer.cornerRadius = 20
        button.tintColor = .white
    }

    func textFieldErrorMessage(_ sender: UILabel, title: String, superTextField: UITextField) {
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

    func errorMessageHidden(_ sender: UILabel) {
        sender.isHidden = true
    }

    func pinCodeErrorMessage(_ text: String, _ pinCodeView: SGCodeTextField) {
        let errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = text
        errorLabel.textColor = .red
        errorLabel.isHidden = false
        errorLabel.font = UIFont.systemFont(ofSize: CGFloat(9))

        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: pinCodeView.bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: pinCodeView.leadingAnchor)
        ])
    }

}
