//
//  TabBarViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/17.
//

import UIKit
import CircleMenu

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCircleBar()
    }

    func setUpCircleBar() {

        let button = CircleMenu(
            frame: CGRect(x: self.tabBar.center.x - 30, y: self.tabBar.center.y - 80, width: 60, height: 60),
            normalIcon:"icon_menu",
            selectedIcon:"icon_close",
            buttonsCount: 2,
            duration: 0.4,
            distance: 120)

        let circleView = UIView(
            frame: CGRect(x: button.center.x - 15, y: button.center.y - 15, width: 30, height: 30)
        )
        circleView.layer.cornerRadius = 15
        circleView.backgroundColor = .white

        self.view.insertSubview(circleView, aboveSubview: button)

        button.subButtonsRadius = 30
        button.delegate = self

        button.layer.cornerRadius = 30

        button.endAngle = Float(-15 * Double.pi)
        button.startAngle = Float(15 * Double.pi)

        self.view.insertSubview(button, aboveSubview: self.tabBar)
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

extension TabBarViewController: CircleMenuDelegate {

}
