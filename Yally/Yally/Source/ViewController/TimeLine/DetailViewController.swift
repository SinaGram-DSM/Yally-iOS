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
import AVFoundation

class DetailViewController: UIViewController {

    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var commentTableView: UITableView!

    private let viewModel = DetailViewModel()
    private let detailData = BehaviorRelay<Void>(value: ())
    private let deleteText = BehaviorRelay<Int>(value: 0)
    private var yallyIndex = BehaviorRelay<Int>(value: 0)
    private var commentIndex = BehaviorRelay<Int>(value: 0)
    private var audioPlayer: AVAudioPlayer?

    var selectIndexPath = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        let CommentTextField = InputTextField()
        view.addSubview(CommentTextField)

        CommentTextField.translatesAutoresizingMaskIntoConstraints = false
        CommentTextField.backgroundColor = .white
        CommentTextField.bottomAnchor.constraint(equalTo: commentTableView.bottomAnchor).isActive = true
        CommentTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        CommentTextField.leadingAnchor.constraint(equalTo: commentTableView.leadingAnchor).isActive = true
        CommentTextField.trailingAnchor.constraint(equalTo: commentTableView.trailingAnchor).isActive = true
        CommentTextField.layer.borderWidth = 0.3

        registerCell()
        bindTableView()
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
        let input = DetailViewModel.input(
            loadDetail: detailData.asSignal(onErrorJustReturn: ()),
            selectIndexPath: selectIndexPath,
            selectYally: yallyIndex.asSignal(onErrorJustReturn: 0),
            deletePost:
                deleteText.asSignal(onErrorJustReturn: 0),
            deleteCommnet: commentIndex.asSignal(onErrorJustReturn: 0))
        let output = viewModel.transform(input)

        DetailViewModel.detailData.asObservable()
            .bind(to: detailTableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { [self] (row, repository, cell) in
                cell.userNameLabel.text = repository.user.nickname
                cell.postTimeLabel.text = repository.createdAt
                cell.mainTextView.text = repository.content
                cell.countOfYally.text = String(repository.yally)
                cell.countOfComment.text = String(repository.comment)
                cell.userImageView.load(urlString: repository.user.img)
                cell.backImageView.load(urlString: repository.img!)

                cell.doYally.rx.tap.subscribe(onNext: { _ in
                    self.yallyIndex.accept(row)
                }).disposed(by: self.rx.disposeBag)

                cell.tapGestureOn.rx.event.subscribe(onNext: { _ in
                    self.play(repository.sound)
//                    player.play()
                }).disposed(by: rx.disposeBag)

                cell.popupTitle.rx.tap.subscribe(onNext: { _ in
                    self.deleteText.accept(row)
                }).disposed(by: self.rx.disposeBag)

                if repository.isMine {
                    cell.popupTitle.setTitle("삭제", for: .normal)
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(updatePost))
                }
            }.disposed(by: rx.disposeBag)

        DetailViewModel.detailComment
            .bind(to: commentTableView.rx.items(cellIdentifier: "commentCell", cellType: CommentTableViewCell.self)) { (row, repository, cell) in
                cell.userImageView.load(urlString: repository.user.img)
                cell.userNameLabel.text = repository.user.nickname
                cell.commentTextView.text = repository.content
                cell.postTimeLabel.text = repository.createdAt

                cell.deleteCommentBtn.rx.tap.subscribe(onNext: { _ in
                    self.commentIndex.accept(row)
                }).disposed(by: self.rx.disposeBag)

                if repository.sound != nil {
                    cell.commentSlider.isHidden = false
                    cell.playBtn.isHidden = false
                    cell.startLabel.isHidden = false
                    cell.lastLabel.isHidden = false
                }

                if repository.isMine {
                    cell.deleteCommentBtn.isHidden = false
                }
            }.disposed(by: rx.disposeBag)
    }

    func play(_ sound: String) {
        guard let url = URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + sound) else { return }
        do {
            print(url)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if audioPlayer != nil {
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
                audioPlayer!.volume = 1.0
            } else {
                //try to load a different resource?
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func downloadFileFromURL(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, _, _ in
            self.play(url: customURL!)
        })
        downloadTask.resume()
    }

    func play(url: URL) {
        do {
            print(url)
            let data = try Data(contentsOf: url)
            audioPlayer = try AVAudioPlayer(data: data)
            print("dd")
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            print(error.localizedDescription)
        }
    }

    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func updatePost() {
        print("select")
    }
}
