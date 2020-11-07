//
//  DetailViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/11/01.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class DetailViewController: UIViewController {

    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var commentTableView: UITableView!

    private let viewModel = DetailViewModel()
    private let detailData = BehaviorRelay<Void>(value: ())

    var selectIndexPath = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        bindTableView()
        // Do any additional setup after loading the view.
    }

    private func registerCell() {
        let mainNib = UINib(nibName: "MainTableViewCell", bundle: nil)
       detailTableView.register(mainNib, forCellReuseIdentifier: "mainCell")

        let commentNib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentTableView.register(commentNib, forCellReuseIdentifier: "commentCell")

        detailTableView.rowHeight = 308
        commentTableView.rowHeight = 104
    }

    func bindTableView() {
        let input = DetailViewModel.input(loadDetail: detailData.asSignal(onErrorJustReturn: ()), selectIndexPath: selectIndexPath)
        let output = viewModel.transform(input)

        DetailViewModel.detailData.asObservable()
            .bind(to: detailTableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { (_, repository, cell) in
            cell.userImageView.image = UIImage(named: repository.user.img)
            cell.userNameLabel.text = repository.user.nickname
            cell.postTimeLabel.text = repository.createdAt
            cell.mainTextView.text = repository.content
            cell.countOfYally.text = String(repository.yally)
            cell.countOfComment.text = String(repository.comment)
            cell.backImageView.image = UIImage(named: repository.img ?? "")
            }.disposed(by: rx.disposeBag)

        DetailViewModel.detailComment
            .bind(to: commentTableView.rx.items(cellIdentifier: "commentCell", cellType: CommentTableViewCell.self)) { (_, repository, cell) in
            cell.userImageView.image = UIImage(named: repository.user.img)
            cell.userNameLabel.text = repository.user.nickname
            cell.commentTextView.text = repository.content
            cell.postTimeLabel.text = repository.createAt
            }.disposed(by: rx.disposeBag)
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
