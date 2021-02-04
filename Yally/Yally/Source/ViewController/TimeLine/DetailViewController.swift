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

final class DetailViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak private var detailTableView: UITableView!
    @IBOutlet weak private var commentTableView: UITableView!
    
    private let viewModel = DetailViewModel()
    private let detailData = BehaviorRelay<Void>(value: ())
    private let deleteText = PublishRelay<Void>()
    private var yallyIndex = PublishRelay<Int>()
    private var commentIndex = PublishRelay<Int>()
    private var recordFile = BehaviorRelay<URL?>(value: nil)
    private var audioPlayer: AVAudioPlayer!
    
    private var timer: Timer!
    private var commentTimer: Timer!
    private let CommentTextField = InputTextField()
    private var isRecord = BehaviorRelay<Bool>(value: false)
    private var recordingSession: AVAudioSession!
    private var recording: AVAudioRecorder!
    private var player = AVAudioPlayer()
    private var commentPlayer = AVAudioPlayer()
    private var playing = BehaviorRelay<Bool>(value: false)
    private var commentPlaying = BehaviorRelay<Bool>(value: false)
    private var originY: CGFloat?
    
    var selectIndexPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(CommentTextField)
        
        CommentTextField.backgroundColor = .white
        CommentTextField.translatesAutoresizingMaskIntoConstraints = false
        CommentTextField.bottomAnchor.constraint(equalTo: commentTableView.bottomAnchor).isActive = true
        CommentTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        CommentTextField.leadingAnchor.constraint(equalTo: commentTableView.leadingAnchor).isActive = true
        CommentTextField.trailingAnchor.constraint(equalTo: commentTableView.trailingAnchor).isActive = true
        CommentTextField.layer.borderWidth = 0.3
        
        registerCell()
        bindViewModel()
        ModifyCommentTyping()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        commentTableView.separatorStyle = .none
        detailTableView.allowsSelection = false
        commentTableView.backgroundColor = .clear
        
        addKeyboardNotification()
        detailData.accept(())
        
        detailTableView.reloadData()
        commentTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        player.pause()
        commentPlayer.pause()
    }
    
    private func registerCell() {
        let mainNib = UINib(nibName: "MainTableViewCell", bundle: nil)
        detailTableView.register(mainNib, forCellReuseIdentifier: "mainCell")
        
        let commentNib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentTableView.register(commentNib, forCellReuseIdentifier: "commentCell")
        
        detailTableView.rowHeight = 308
    }
    
    func bindViewModel() {
        let input = DetailViewModel.input(
            loadDetail: detailData.asSignal(onErrorJustReturn: ()),
            selectIndexPath: selectIndexPath,
            selectYally: yallyIndex.asSignal(onErrorJustReturn: 0),
            deletePost: deleteText.asSignal(onErrorJustReturn: ()),
            deleteCommnet: commentIndex.asSignal(onErrorJustReturn: 0),
            commentContent: CommentTextField.commentTextView.rx.text.orEmpty.asDriver(),
            commentRecord: recordFile.asDriver(onErrorJustReturn: nil),
            commentTap: CommentTextField.sendBtn.rx.tap.asDriver())
        let output = viewModel.transform(input)
        
        DetailViewModel.detailData.asObservable()
            .bind(to: detailTableView.rx.items(cellIdentifier: "mainCell", cellType: MainTableViewCell.self)) { [unowned self] (row, repository, cell) in
                
                cell.userNameLabel.text = repository.user.nickname
                cell.postTimeLabel.text = repository.createdAt
                cell.mainTextView.text = repository.content
                cell.countOfYally.text = String(repository.yally)
                cell.countOfComment.text = String(repository.comment)
                cell.userImageView.load(urlString: repository.user.img)
                cell.backImageBtn.load(url: repository.img!)
                cell.doYally.isSelected = repository.isYally
                
                cell.backImageBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
                    if playing.value {
                        let realURL = self.fetchNonObsevable(url: URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + repository.sound)!)
                        if let url = realURL {
                            player = try! AVAudioPlayer(contentsOf: url)
                            player.delegate = self
                            player.volume = 1.0
                            player.play()
                        }
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                            if cell.sliderBar.isTracking { return }
                            cell.sliderBar.maximumValue = Float(player.duration)
                            cell.sliderBar.value = Float(player.currentTime)
                            cell.timeLabel.text = self.stringFromTimeInterval(interval: player.currentTime)
                        })
                    } else {
                        player.pause()
                    }
                    cell.timeLabel.text = self.stringFromTimeInterval(interval: TimeInterval(cell.sliderBar.value))
                    playing.accept(!playing.value)
                }).disposed(by: self.rx.disposeBag)
                
                cell.doYally.rx.tap.subscribe(onNext: { _ in
                    yallyIndex.accept(row)
                }).disposed(by: cell.disposeBag)
                
                cell.popupTitle.rx.tap.bind(to: deleteText).disposed(by: cell.disposeBag)
                
                cell.sliderBar.rx.value.subscribe(onNext: { _ in
                    player.currentTime = TimeInterval(cell.sliderBar.value)
                }).disposed(by: cell.disposeBag)
                
                if repository.isMine {
                    cell.popupTitle.setTitle("삭제", for: .normal)
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "수정", style: .plain, target: self, action: nil)
                    navigationItem.rightBarButtonItem!.rx.tap.subscribe(onNext: { _ in
                        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "uploadVC") as? UploadViewController else { return }
                        vc.selectIndexPath = selectIndexPath
                        vc.viewImg.accept(repository.img)
                        vc.firstAudio.accept(repository.sound)
                        vc.content = repository.content
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }).disposed(by: rx.disposeBag)
                }
            }.disposed(by: rx.disposeBag)
        
        DetailViewModel.detailComment
            .bind(to: commentTableView.rx.items(cellIdentifier: "commentCell", cellType: CommentTableViewCell.self)) { (row, repository, cell) in
                
                cell.configCell(repository)
                
                cell.playBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
                    if !commentPlaying.value {
                        commentPlayer.play()
                        let realURL = self.fetchNonObsevable(url: URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + repository.sound!)!)
                        if let url = realURL {
                            commentPlayer = try! AVAudioPlayer(contentsOf: url)
                            commentPlayer.delegate = self
                            commentPlayer.volume = 1.0
                            commentPlayer.play()
                        }
                        commentTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                            if cell.commentSlider.isTracking { return }
                            cell.commentSlider.maximumValue = Float(commentPlayer.duration)
                            cell.commentSlider.value = Float(commentPlayer.currentTime)
                            cell.lastLabel.text = self.stringFromTimeInterval(interval: self.commentPlayer.currentTime)
                        })
                    } else {
                        commentPlayer.stop()
                    }
                    
                    cell.lastLabel.text = self.stringFromTimeInterval(interval: TimeInterval(cell.commentSlider.value))
                    commentPlaying.accept(!commentPlaying.value)
                }).disposed(by: cell.disposeBag)
                
                cell.deleteCommentBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
                    commentIndex.accept(row)
                }).disposed(by: cell.disposeBag)
                
                cell.commentSlider.rx.value.subscribe(onNext: {[unowned self] _ in
                    commentPlayer.currentTime = TimeInterval(cell.commentSlider.value)
                }).disposed(by: cell.disposeBag)
                
                if repository.sound != nil {
                    cell.commentSlider.isHidden = false
                    cell.playBtn.isHidden = false
                    cell.startLabel.isHidden = false
                    cell.lastLabel.isHidden = false
                    self.commentTableView.rowHeight = 104
                }else {
                    self.commentTableView.rowHeight = CGFloat(70 + (repository.content.count/30) * 20)
                }
                
            }.disposed(by: rx.disposeBag)
        
        output.postComment.withLatestFrom(output.deleteComment).emit(onCompleted: {[unowned self] in
            detailData.accept(())
            commentTableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.postYally.withLatestFrom(output.deleteYally).emit(onCompleted: { [unowned self] in
            detailData.accept(())
            detailTableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.deletePost.emit(onCompleted: {[unowned self] in
            navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func startRecording() {
        let fileName = NSUUID().uuidString + ".aac"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let audioFileName = paths[0].appendingPathComponent(fileName)
        let setting = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recording = try AVAudioRecorder(url: audioFileName, settings: setting)
            recording?.delegate = self
            recording?.record(forDuration: 300)
        } catch {
            recording?.stop()
        }
    }
    
    func finishRecording(success: Bool) {
        recording.stop()
        if success {
            print("record successfully")
        } else {
            recording = nil
            print("recording failed!")
        }
    }
    
    private func ModifyCommentTyping() {
        CommentTextField.recordBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            if !isRecord.value {
                startRecording()
                isRecord.accept(true)
            } else {
                finishRecording(success: true)
                isRecord.accept(false)
            }
        }).disposed(by: rx.disposeBag)
        
        CommentTextField.sendBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            CommentTextField.commentTextView.text = ""
        }).disposed(by: rx.disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        guard let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        self.view.frame.origin.y = 0 - keyboardSize.height + CommentTextField.commentTextView.frame.height
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

extension DetailViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordFile.accept(recorder.url)
    }
}
