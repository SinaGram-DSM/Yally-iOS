//
//  ListeningTableViewController.swift
//  Yally
//
//  Created by 문지수 on 2020/10/27.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx

class ListeningTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()
    let viewModel = ListenViewModel()
    let loadData = BehaviorSubject<Void>(value: ())
    let loadUser = BehaviorSubject<Void>(value: ())

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //setUI()
        bindViewModel()

    }

    func bindViewModel() {
        let input = ListenViewModel.input(loadData: loadData.asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input)

        output.loadApplyList.map(CollectionOfOne.init).bind(to: tableView.rx.items) { tableView, index, element -> UITableViewCell in
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "ListeningTableViewCell") as? ListeningTableViewCell else {
                return ListeningTableViewCell()
            }
            cell.nickNameLbl.text = element.listen[index].nickname
            cell.profileImage.image = UIImage(named: element.listen[index].image)
            return cell
        }.disposed(by: disposeBag)

    }

//    func setUI() {
//        let cell = ListeningTableViewCell()
//        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width/2
//        cell.unListeningBtn.layer.cornerRadius = 15
//
//    }

    private func registerCell() {
        tableView.rowHeight = 70
    }
}

extension UIViewController {
    func setButton(_ button: UIButton, _ isSelect: Bool) {
        if isSelect {
            button.backgroundColor = .lightPurple
            button.isSelected = false
        } else {
            button.backgroundColor = .purpley
        }
    }
}
