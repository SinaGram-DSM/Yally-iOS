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
