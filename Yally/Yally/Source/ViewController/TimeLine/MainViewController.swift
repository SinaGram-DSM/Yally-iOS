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
import Alamofire

final class MainViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private let viewModel = MainViewModel()
    private let loadData = BehaviorRelay<Void>(value: ())
    private let loadMoreData = PublishRelay<Int>()
    private var selectDelete = PublishRelay<Int>()
    private let selectItems = PublishRelay<Int>()
    private var player = AVAudioPlayer()
    private var timer: Timer!
    private var playing = BehaviorRelay<Bool>(value: false)
    private var count: Int = 2
    private var scoll: Bool = false
    var selectIndexPath = PublishRelay<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        configureTableView()
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
    
    private func bindViewModel() {
        let input = MainViewModel.input(
            loadData: loadData.asSignal(onErrorJustReturn: ()),
            loadMoreData: loadMoreData.asSignal(onErrorJustReturn: 0),
            selectCell: selectItems.asSignal(onErrorJustReturn: 0),
            selectIndexPath: selectIndexPath.asSignal(onErrorJustReturn: 0),
            selectDelete: selectDelete.asSignal(onErrorJustReturn: 0)
        )
        let output = viewModel.transform(input)
        
        tableView.rx.itemSelected.subscribe(onNext: {[unowned self] index in
            selectItems.accept(index.row)
        }).disposed(by: rx.disposeBag)
        
        output.loadData.bind(to: tableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { (row, repository, cell) in
            
            cell.configCell(repository)
            
            cell.backImageBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
                if playing.value {
                    let realURL = fetchNonObsevable(url: URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + repository.sound)!)
                    if let url = realURL {
                        player = try! AVAudioPlayer(contentsOf: url)
                        player.delegate = self
                        player.volume = 1.0
                        player.play()
                    }
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                        if cell.sliderBar.isTracking {
                            return
                        }
                        cell.sliderBar.maximumValue = Float(player.duration)
                        cell.sliderBar.value = Float(player.currentTime)
                        cell.timeLabel.text = self.stringFromTimeInterval(interval: player.currentTime)
                    })
                } else {
                    self.player.stop()
                }
                cell.timeLabel.text = self.stringFromTimeInterval(interval: TimeInterval(cell.sliderBar.value))
                playing.accept(!playing.value)
            }).disposed(by: cell.disposeBag)
            
            cell.sliderBar.rx.value.subscribe(onNext: {[unowned self] _ in
                player.currentTime = TimeInterval(cell.sliderBar.value)
            }).disposed(by: cell.disposeBag)
            
            cell.doYally.rx.tap.subscribe(onNext: {[unowned self] _ in
                selectIndexPath.accept(row)
            }).disposed(by: cell.disposeBag)
            
            cell.doComment.rx.tap.subscribe(onNext: {[unowned self] _ in
                selectItems.accept(row)
            }).disposed(by: cell.disposeBag)
            
            cell.popupTitle.rx.tap.subscribe(onNext: {[unowned self] _ in
                selectDelete.accept(row)
            }).disposed(by: cell.disposeBag)
            
            if repository.isMine {
                cell.popupTitle.setTitle("삭제", for: .normal)
            }
        }.disposed(by: rx.disposeBag)
        
        Observable.of(output.deletePost, output.yallyPost, output.yallyDelete).subscribe(onNext: {[unowned self] _ in
            loadData.accept(())
            tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.loadMoreData.subscribe(onNext: {[unowned self] data in
            for i in 0..<data.count {
                output.loadData.add(element: data[i])
            }
            tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.nextView.asObservable().subscribe(onNext: { id in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else { return }
            vc.selectIndexPath = id
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "MainTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "mainCell")
        
        tableView.rx.didScroll.asObservable().subscribe(onNext: {[unowned self] _ in
            player.pause()
            if tableView.contentOffset.y > tableView.contentSize.height - tableView.bounds.size.height {
                if scoll {
                    loadMoreData.accept(self.count)
                    tableView.reloadData()
                    count += 1
                }
            } else {
                scoll = !scoll
            }
        }).disposed(by: rx.disposeBag)
    }
    
    private func configureTableView() {
        registerCell()
        tableView.rowHeight = 308
    }
}

extension MainViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player.pause()
    }
}

//Extension 파일에 합칠 것
extension UIViewController {

    func defaultBtn(_ button: UIButton) {
        button.layer.cornerRadius = 14
        button.backgroundColor = UIColor().hexUIColor(hex: "efefef")
        button.tintColor = .darkGray
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
        }
        
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

extension UIColor {
    func hexUIColor(hex: String) -> UIColor {
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: CGFloat(1.0)
        )
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

extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    var positionalTime: String {
        
        return String(format: "%02d:%02d", minute, second)
    }
}
