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
import AVFoundation

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let viewModel = MainViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private let loadMoreData = BehaviorRelay<Int>(value: 0)
    private var selectIndexPath = BehaviorRelay<Int>(value: 0)
    private var selectDelete = BehaviorRelay<Int>(value: 0)
    //    private var isAvailable = BehaviorRelay<Void>(value: ())

    var check = Bool()
    var isAvailable = Bool()
    var page = 1
    var player: AVAudioPlayer!

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
            loadMoreData: loadMoreData.asSignal(onErrorJustReturn: 0),
            selectCell: tableView.rx.itemSelected.asSignal(),
            selectIndexPath: selectIndexPath.asSignal(onErrorJustReturn: 0),
            selectDelete: selectDelete.asSignal(onErrorJustReturn: 0)
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
                cell.doYally.isSelected = repository.isYally
                cell.userImageView.load(urlString: repository.user.img)
                cell.backImageView.load(urlString: repository.img!)

                cell.doYally.rx.tap.subscribe(onNext: { _ in
                    cell.doYally.isSelected = !cell.doYally.isSelected
                    self.selectIndexPath.accept(row)
                }).disposed(by: self.rx.disposeBag)

                cell.doComment.rx.tap.subscribe(onNext: { _ in
                    self.nextView("detailVC")
                }).disposed(by: self.rx.disposeBag)

                cell.popupTitle.rx.tap.subscribe(onNext: { _ in
                    self.selectDelete.accept(row)
                }).disposed(by: self.rx.disposeBag)

                if repository.isMine {
                    cell.popupTitle.setTitle("삭제", for: .normal)
                }

                self.check = true

            }.disposed(by: rx.disposeBag)

        output.data.drive().disposed(by: rx.disposeBag)
        output.data.drive(onNext: { _ in self.tableView.reloadData()}).disposed(by: rx.disposeBag)
        output.deletePost.drive(onNext: { _ in
            print("reload")
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.yallyPost.drive(onCompleted: {
            self.tableView.reloadData()
            self.loadData.accept(())
        }).disposed(by: rx.disposeBag)

        output.yallyDelete.drive(onCompleted: {
            self.tableView.reloadData()
            self.loadData.accept(())
        }).disposed(by: rx.disposeBag)

        output.nextView.asObservable().subscribe(onNext: { id in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
            vc.selectIndexPath = id
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }

    private func registerCell() {
        let api = TimeLineAPI()

        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "mainCell")

        tableView.rx.didScroll.asObservable().subscribe(onNext: { _ in
            if self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.bounds.size.height {
                if self.check {
                    self.loadMoreData.accept(2)
                }
                self.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
    }

    private func configureTableView() {
        registerCell()
        tableView.rowHeight = 308
    }
}

extension MainViewController: UITableViewDelegate {

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

extension UIImageView {
    func load(urlString : String) {
        guard let url = URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
