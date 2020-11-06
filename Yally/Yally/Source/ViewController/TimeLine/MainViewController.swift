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

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = MainViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private let loadMoreData = BehaviorRelay<Void>(value: ())
    private var selectIndexPath = BehaviorRelay<Int>(value: 0)
    private let label = UILabel()

    //VC는 Model을 알면 안됨...

    private var isAvailable = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    func bindViewModel() {
        let input = MainViewModel.input(
            loadData: loadData.asSignal(onErrorJustReturn: ()),
            loadMoreData: loadMoreData.asSignal(onErrorJustReturn: ()),
            selectCell: tableView.rx.itemSelected.asSignal(),
            selectIndexPath: selectIndexPath.asSignal(onErrorJustReturn: 0)
        )
        let output = viewModel.transform(input)

        MainViewModel.loadData
            .bind(to: tableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { (row, repository, cell) in
                cell.userImageView.image = UIImage(named: repository.user.img)
                cell.userNameLabel.text = repository.user.nickname
                cell.postTimeLabel.text = repository.createdAt
                cell.mainTextView.text = repository.content
                cell.countOfYally.text = String(repository.yally)
                cell.countOfComment.text = String(repository.comment)
                cell.backImageView.image = UIImage(named: repository.img ?? "")
                self.setButton(cell.doYally, repository.isYally)

                cell.doYally.rx.tap.subscribe(onNext: { _ in
                    print(row)
                    self.selectIndexPath.accept(row)
                }).disposed(by: self.rx.disposeBag)

                cell.doComment.rx.tap.subscribe(onNext: { _ in
                    self.nextView("detailVC")
                }).disposed(by: self.rx.disposeBag)

            }.disposed(by: rx.disposeBag)

        output.data.drive().disposed(by: rx.disposeBag)
        output.data.drive(onNext: { _ in self.tableView.reloadData()}).disposed(by: rx.disposeBag)

        output.nextView.asObservable().subscribe(onNext: { id in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
            vc.selectIndexPath = id
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }

    private func registerCell() {
        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
       tableView.register(nib, forCellReuseIdentifier: "mainCell")
    }

    private func configureTableView() {
        registerCell()
        tableView.rowHeight = 308
    }
}

extension UIViewController {
    func setButton(_ button: UIButton, _ isSelect: Bool) {
        if isSelect {
            button.tintColor = .gray
            button.isSelected = false
        } else {
            button.tintColor = .purple
            button.isSelected = true
        }
    }

    func nextView(_ identifier: String) {
        let vc = self.storyboard?.instantiateViewController(identifier: identifier)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
