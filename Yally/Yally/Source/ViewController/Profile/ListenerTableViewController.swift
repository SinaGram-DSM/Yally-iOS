//
//  ListenerTableViewController.swift
//  Yally
//
//  Created by 문지수 on 2020/11/03.
//

import UIKit

import RxSwift
import RxCocoa

class ListenerTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()
    let viewModel = ListenViewModel()
    let loadData = BehaviorSubject<Void>(value: ())

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        setUI()
        bindViewModel()
    }

    func bindViewModel() {
        let input = ListenViewModel.input(loadData: loadData.asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input)

        output.loadApplyList.map(CollectionOfOne.init).bind(to: tableView.rx.items) {tableView, index, element -> UITableViewCell in
                    guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "ListenerTableViewCell") as? ListenerTableViewCell else { return ListenerTableViewCell()}
            cell.nickNameLabel.text = element.listen[index].nickname
            cell.profileImage.image = UIImage(named:element.listen[index].image)
            return cell
        }.disposed(by: disposeBag)

    }

    func setUI() {
        let cell = ListenerTableViewCell()
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width/2
        cell.listeningBtn.layer.cornerRadius = 15
    }

    private func registerCell() {
        tableView.rowHeight = 70
    }

}
