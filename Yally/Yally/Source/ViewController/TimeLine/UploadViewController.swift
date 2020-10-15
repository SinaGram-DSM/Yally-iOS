//
//  UploadViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/11/28.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import AVFoundation
import MediaPlayer
import Alamofire

final class UploadViewController: UIViewController {
    
    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var postTextView: UITextView!
    @IBOutlet weak private var lineView: UIView!
    @IBOutlet weak private var recordingBtn: UIButton!
    @IBOutlet weak private var fileBtn: UIButton!
    @IBOutlet weak private var coverBtn: UIButton!
    @IBOutlet private var previewImg: [UIImageView]!
    @IBOutlet private var previewDelete: [UIButton]!
    @IBOutlet weak private var recordView: UIImageView!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var guardLabel: UILabel!
    
    private let viewModel = UploadViewModel()
    private var recordingSession: AVAudioSession!
    private var recording: AVAudioRecorder!
    private let hashtag: [String] = []
    private var isRecord = BehaviorRelay<Bool>(value: false)
    private var selectImg = BehaviorRelay<Data?>(value: nil)
    private var audioFile = BehaviorRelay<URL?>(value: nil)
    private var uploadBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: nil)
    
    var content = String()
    var selectIndexPath = String()
    var firstAudio = BehaviorRelay<String?>(value: nil)
    var viewImg = BehaviorRelay<String?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        beforeUpload()
        
        postTextView.text = content
        navigationItem.rightBarButtonItem = uploadBtn
    
        defaultBtn(recordingBtn)
        defaultBtn(fileBtn)
        defaultBtn(coverBtn)
        
        postTextView.delegate = self
    }
    
    private func beforeUpload() {
        let realURL = self.fetchNonObsevable(url: URL(string: "https://yally-sinagram.s3.ap-northeast-2.amazonaws.com/" + firstAudio.value!)!)
        if let url = realURL {
            audioFile.accept(url)
        }
        
        fileBtn.rx.tap.subscribe(onNext: { _ in
            let alert = UIAlertController(title: "죄송합니다", message: "준비 중인 서비스 입니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "네", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        coverBtn.rx.tap.subscribe(onNext: { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        previewDelete[1].rx.tap.subscribe(onNext: {[unowned self] _ in
            previewImg[1].isHidden = true
            previewDelete[1].isHidden = true
        }).disposed(by: rx.disposeBag)
        
        previewDelete[0].rx.tap.subscribe(onNext: {[unowned self] _ in
            previewImg[0].isHidden = true
            previewDelete[0].isHidden = true
        }).disposed(by: rx.disposeBag)
        
        recordView.isHidden = true
        timeLabel.isHidden = true
        guardLabel.isHidden = true
        
        previewImg[1].load(urlString: viewImg.value!)
        
        recordingBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            if !isRecord.value {
                startRecording()
                setTimer()
                
                recordView.isHidden = false
                timeLabel.isHidden = false
                guardLabel.isHidden = false
                isRecord.accept(true)
            } else {
                finishRecording(success: true)
                setTimer()
                
                recordView.isHidden = true
                timeLabel.isHidden = true
                guardLabel.isHidden = true
                isRecord.accept(false)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    private func bindViewModel() {
        let input = UploadViewModel.input(
            selectIndexPath: selectIndexPath,
            postText: postTextView.rx.text.orEmpty.asDriver(),
            selectFile: audioFile.asDriver(),
            selectCover: selectImg.asDriver(),
            doneTap: uploadBtn.rx.tap.asDriver(onErrorJustReturn: ()))
        let output = viewModel.transform(input)
        
        output.result.emit(onCompleted: {[unowned self] in
            navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        
        output.isEnable.drive(onNext: {[unowned self] enable in
            uploadBtn.isEnabled = enable
        }).disposed(by: rx.disposeBag)
    }
    
    private func setupView() {
        lineView.backgroundColor = .gray
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try? recordingSession.setCategory(.record, mode: .default)
            try? recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self!.loadRecordingUI()
                    } else {
                        // failed to record
                    }
                }
            }
        }
    }
    
    private func loadRecordingUI() {
        recordingBtn.isSelected = true
        recordView.isHidden = false
        timeLabel.isHidden = false
        guardLabel.isHidden = false
        recordView.backgroundColor = .red
        recordView.layer.cornerRadius = 10
    }
    
    private func setTimer() {
        isRecord.asObservable().flatMapLatest {  isRecord in
            isRecord ? Observable<Int>.interval(1, scheduler: MainScheduler.instance) : .empty()
        }.subscribe(onNext: { value in
            if value == 300 {
                .recording.stop()
                self.finishRecording(success: true)
                self.isRecord.accept(false)
            }
            timeLabel.text = String(value).formatTimer(value)
        }).disposed(by: rx.disposeBag)
    }
    
    private func startRecording() {
        let audioFileName = getFileURL()
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
    
    private func finishRecording(success: Bool) {
        recording.stop()
        if success {
            print("record successfully")
            previewImg[0].isHidden = false
            previewDelete[0].isHidden = false
        } else {
            recording = nil
            print("recording failed!")
        }
    }
    
    private func getFileURL() -> URL {
        let fileName = NSUUID().uuidString + ".aac"
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension UploadViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioFile.accept(recorder.url)
    }
}

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let data: Data? = image.jpegData(compressionQuality: 0.2)
            selectImg.accept(data)
            previewImg[1].image = image
            previewImg[1].isHidden = false
            previewDelete[1].isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
}

extension UploadViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let text = textView.text else { return true }
        let newLength = text.count - range.length
        return newLength <= 100
    }
}
