//
//  ProfileViewController.swift
//  Yally
//
//  Created by 문지수 on 2020/10/03.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import AVFoundation
import Alamofire

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var listeningBtn: UIButton!
    @IBOutlet weak var listeningValue: UIButton!
    @IBOutlet weak var listeningValueLbl: UILabel!
    @IBOutlet weak var listenerBtn: UIButton!
    @IBOutlet weak var listenerValue: UIButton!
    @IBOutlet weak var listenerValueLbl: UILabel!
    @IBOutlet weak var modifyBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private let viewModel = ProfileViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private var selectIndexPath = PublishRelay<Int>()
    private var selectDelete = PublishRelay<Int>()
    private let selectItems = PublishRelay<Int>()

    var player = AVAudioPlayer()
    var timer: Timer!
    var playing = BehaviorRelay<Bool>(value: false)
    var count: Int = 2
    var scoll: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        setUI()
        bindViewModel()
        registerCell()
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        loadData.accept(())
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        player.pause()
    }

    func bindViewModel() {
        let input = ProfileViewModel.input(loadData: loadData.asSignal(onErrorJustReturn: ()))
        let output = viewModel.transform(input)

        ProfileViewModel.loadData.asObservable().subscribe(onNext: { result in
            self.nameLabel.text = result.nickname
            self.listenerValueLbl.text = "\(result.listener)"
            self.listeningValueLbl.text = "\(result.listening)"

        }).disposed(by: disposeBag)

        output.result.emit(onCompleted: {
            self.loadData.accept(())
        }).disposed(by: disposeBag)

        output.loadData.bind(to: tableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { (row, repository, cell) in
            cell.userImageView.image = UIImage(named: repository.user.img)
            cell.userNameLabel.text = repository.user.nickname
            cell.postTimeLabel.text = repository.createdAt
            cell.mainTextView.text = repository.content
            cell.countOfYally.text = repository.content
            cell.countOfComment.text = String(repository.comment)
            cell.doYally.isSelected = repository.isYally
            cell.userImageView.load(urlString: repository.user.img)
            cell.backImageBtn.load(url: repository.img)

            cell.backImageBtn.rx.tap.subscribe(onNext: { _ in
                if self.playing.value {
                    let realURL = self.fetchNonObsevable(url: URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + repository.sound! ?? "")!)
                    if let url = realURL {
                        self.player = try! AVAudioPlayer(contentsOf: url)
                        self.player.delegate = self
                        self.player.volume = 1.0
                        self.player.play()
                    }
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                        if cell.sliderBar.isTracking {
                            return
                        }
                        cell.sliderBar.maximumValue = Float(self.player.duration)
                        cell.sliderBar.value = Float(self.player.currentTime)
                        cell.timeLabel.text = self.stringFromTimeInterval(interval: self.player.currentTime)
                        })
                    } else {
                        self.player.pause()
                }

                cell.timeLabel.text = self.stringFromTimeInterval(interval: TimeInterval(cell.sliderBar.value))
                self.playing.accept(!self.playing.value)
            }).disposed(by: cell.disposeBag)

            cell.sliderBar.rx.value.subscribe(onNext: { _ in
                self.player.currentTime = TimeInterval(cell.sliderBar.value)
            }).disposed(by: cell.disposeBag)

            cell.doYally.rx.tap.subscribe(onNext: { _ in
                self.selectIndexPath.accept(row)
            }).disposed(by: cell.disposeBag)

            cell.doComment.rx.tap.subscribe(onNext: { _ in
                self.selectItems.accept(row)
            }).disposed(by: cell.disposeBag)

            cell.popupTitle.rx.tap.subscribe(onNext: { _ in
                self.selectDelete.accept(row)
            }).disposed(by: cell.disposeBag)

            if repository.isMine {
                cell.popupTitle.setTitle("삭제", for: .normal)
            }
        }.disposed(by: disposeBag)

        output.deletePost.drive(onNext: { _ in
            self.loadData.accept(())
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.yallyPost.drive(onNext: { _ in
            self.loadData.accept(())
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.yallyDelete.drive(onNext: { _ in
            self.loadData.accept(())
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)

        output.loadMoreData.subscribe(onNext: { data in
            for i in 0..<data.count {
                output.loadData.add(element: data[i])
            }
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)

        }

    private func registerCell() {
        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "mainCell")
        tableView.rowHeight = 308
        }

    func setUI() {

        self.navigationItem.title = "프로필"

        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true

    }
}

extension UIColor {

    class var cornflowerBlue: UIColor {
      return UIColor(red: 71.0 / 255.0, green: 118.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
    }
    class var purpley: UIColor {
      return UIColor(red: 142.0 / 255.0, green: 84.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0)
    }
    class var lightPurple: UIColor {
      return UIColor(red: 175.0 / 255.0, green: 134.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    }
    class var veryLightPink: UIColor {
      return UIColor(white: 239.0 / 255.0, alpha: 1.0)
    }
    class var gray: UIColor {
        return UIColor(red: 122.0/255.0, green: 122.0/255.0, blue: 122.0/255.0, alpha: 1.0)
    }

}

extension ProfileViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player.pause()
    }
}

extension UIViewController {

    func nextView(_ identifier: String) {
        let vc = self.storyboard?.instantiateViewController(identifier: identifier)
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func fetchNonObsevable(url: URL?) -> URL? {
        guard let url = url else { return URL(string: "")! }

        let documentURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let fileURL = documentURL.appendingPathComponent(url.lastPathComponent)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("already have file")
            return fileURL
        } // 파일이 이미 있는경우
        let destination: DownloadRequest.Destination = { _, _ in
            return (fileURL, [.removePreviousFile,
                              .createIntermediateDirectories])
        }
        var returnURL: URL?

        AF.download(
            url,
            to: destination
        ).response { response in
            switch response.result {
            case .success(let url):
                guard let url = url else { return }
                returnURL = url
            case .failure(let err):
                print(err.localizedDescription)
            }
        }

        return returnURL
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

extension UIButton {
    func load(url: String) {
        guard let url = URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + url)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.setBackgroundImage(image, for: .normal)
                    }
                }
            }
        }
    }
}
