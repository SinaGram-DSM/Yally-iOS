//
//  TabBarViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit
import CircleMenu

final class TabBarViewController: UITabBarController {
    private let circleBtn = CircleMenu(
        frame: CGRect(),
        normalIcon: "",
        selectedIcon: "",
        buttonsCount: 2,
        duration: 0.4,
        distance: 120
    )
    
    private let circleView = UIView(
        frame: CGRect()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleBtn.delegate = self
        
        circleBtn.frame = CGRect(x: tabBar.center.x - 30, y: tabBar.center.y - 80, width: 60, height: 60)
        circleView.frame = CGRect(x: circleBtn.center.x - 15, y: circleBtn.center.y - 15, width: 30, height: 30)
        
        circleView.layer.cornerRadius = 15
        circleBtn.layer.cornerRadius = 30
        circleBtn.subButtonsRadius = 30
        
        circleView.backgroundColor = .white
        circleBtn.setGradient(color1: UIColor().hexUIColor(hex: "4776e6"), color2: UIColor().hexUIColor(hex: "8e54e9"), radius: 30)
        
        view.insertSubview(circleView, aboveSubview: circleBtn)
        
        circleBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        circleBtn.endAngle = Float(-15 * Double.pi)
        circleBtn.startAngle = Float(15 * Double.pi)
        
        view.insertSubview(circleBtn, aboveSubview: tabBar)
    }
    
    func menuOpened(_ circleMenu: CircleMenu) {
        circleBtn.bounds.size.width = 80
        circleBtn.bounds.size.height = 80
        circleView.bounds.size.height = 40
        circleView.bounds.size.width = 40
        circleView.layer.cornerRadius = 20
        circleBtn.setGradient(color1: UIColor().hexUIColor(hex: "4776e6"), color2: UIColor().hexUIColor(hex: "8e54e9"), radius: 40)
    }
    
    func menuCollapsed(_ circleMenu: CircleMenu) {
        circleBtn.bounds.size.width = 60
        circleBtn.bounds.size.height = 60
        circleView.bounds.size.height = 30
        circleView.bounds.size.width = 30
        circleView.layer.cornerRadius = 15
        circleBtn.setGradient(color1: UIColor().hexUIColor(hex: "4776e6"), color2: UIColor().hexUIColor(hex: "8e54e9"), radius: 30)
    }
    
}

extension TabBarViewController: CircleMenuDelegate {
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        if atIndex == 1 {
            let mainView: UIStoryboard = UIStoryboard(name: "Posting", bundle: nil)
            let VC = mainView.instantiateViewController(identifier: "postVC") as PostViewController
            navigationController?.pushViewController(VC, animated: true)
        } else {
            //검색
        }
        
    }
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 0.3
        
        if atIndex == 1 {
            button.setBackgroundImage(UIImage(named: "edit-icon"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "profile-icon"), for: .normal)
        }
        button.backgroundColor = .white
    }
}

//merge하고 Extension으로 ,,
extension UIView {
    static let gradient: CAGradientLayer = CAGradientLayer()
    
    func setGradient(color1:UIColor, color2:UIColor, radius: CGFloat) {
        UIView.gradient.colors = [color1.cgColor, color2.cgColor]
        UIView.gradient.locations = [0.0, 1.0]
        UIView.gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        UIView.gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        UIView.gradient.frame = bounds
        UIView.gradient.cornerRadius = radius
        layer.addSublayer(UIView.gradient)
    }
}
