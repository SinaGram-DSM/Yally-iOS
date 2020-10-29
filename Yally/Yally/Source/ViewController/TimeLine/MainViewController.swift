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

    private let label = UILabel()
    //VC는 Model을 알면 안됨...
    private let loadPosts = BehaviorRelay<[MainModel]>(value: [])
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
        let input = MainViewModel.input(loadData: loadData.asSignal(onErrorJustReturn: ()), loadMoreData: loadMoreData.asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input)

        MainViewModel.loadData
            .bind(to: tableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { (_, repository, cell) in
                cell.userImageView.image = UIImage(named: repository.user.img)
                cell.userNameLabel.text = repository.user.nickname
                cell.postTimeLabel.text = repository.createdAt
                cell.mainTextView.text = repository.content
                cell.countOfYally.text = String(repository.yally)
                cell.countOfComment.text = String(repository.comment)
                cell.backImageView.image = UIImage(named: repository.img ?? "")
            }.disposed(by: rx.disposeBag)

        if isAvailable {
            MainViewModel.loadMoreData.bind(to: tableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { (_, repository, cell) in
                cell.userImageView.image = UIImage(named: repository.user.img)
                cell.userNameLabel.text = repository.user.nickname
                cell.postTimeLabel.text = repository.createdAt
                cell.mainTextView.text = repository.content
                cell.countOfYally.text = String(repository.yally)
                cell.countOfComment.text = String(repository.comment)
                cell.backImageView.image = UIImage(named: repository.img ?? "")
            }.disposed(by: rx.disposeBag)

        }
        output.data.drive().disposed(by: rx.disposeBag)
        output.data.drive(onNext: { _ in self.tableView.reloadData()}).disposed(by: rx.disposeBag)
    }

    private func registerCell() {
        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
       tableView.register(nib, forCellReuseIdentifier: "mainCell")
    }

    private func configureTableView() {
        registerCell()
        tableView.rowHeight = 308

        tableView.rx.didScroll.subscribe(onNext: { _ in
            if self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.bounds.size.height {
                if self.isAvailable {
                    self.isAvailable = true
                }
                self.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
    }
}
