//
//  MainViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/18.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class MainViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func setUpTableView() {
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
    }

    private func initDateSource(_ nibName: String) {
//        self.tableView.rx.items(cellIdentifier: nibName, cellType: )
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
