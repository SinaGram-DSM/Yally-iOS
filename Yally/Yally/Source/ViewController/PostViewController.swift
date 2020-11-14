//
//  PostViewController.swift
//  Yally
//
//  Created by 이가영 on 2020/10/19.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import AVFoundation
import MediaPlayer

class PostViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var recordingBtn: UIButton!
    @IBOutlet weak var fileBtn: UIButton!
    @IBOutlet weak var coverBtn: UIButton!
    @IBOutlet var previewImg: [UIImageView]!
    @IBOutlet var previewDelete: [UIButton]!
    @IBOutlet weak var uploadBtn: UIBarButtonItem!
    @IBOutlet weak var recordView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var guardLabel: UILabel!

    var recordingSession: AVAudioSession!
    var recording: AVAudioRecorder!
    let hashtag: [String] = []
    var isRecord = BehaviorRelay<Bool>(value: false)
    var timeFlow = BehaviorRelay<Int>(value: 0)

    private let viewModel = PostViewModel()
    private var selectImg = BehaviorRelay<Data?>(value: nil)
    private var audioFile = PublishRelay<URL>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        fileBtn.rx.tap.subscribe(onNext: { _ in
            let mediaPicker: MPMediaPickerController = MPMediaPickerController.self(mediaTypes:MPMediaType.music)
            mediaPicker.delegate = self
            mediaPicker.allowsPickingMultipleItems = true

            self.present(mediaPicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        coverBtn.rx.tap.subscribe(onNext: { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        previewDelete[1].rx.tap.subscribe(onNext: { _ in
            self.previewImg[1].isHidden = true
            self.previewDelete[1].isHidden = true
        }).disposed(by: rx.disposeBag)

        previewDelete[0].rx.tap.subscribe(onNext: { _ in
            self.previewImg[0].isHidden = true
            self.previewDelete[0].isHidden = true
        }).disposed(by: rx.disposeBag)

        recordingBtn.rx.tap.subscribe(onNext: { _ in
            if !self.isRecord.value {
                self.startRecording()
                self.setTimer()

                self.recordView.isHidden = false
                self.timeLabel.isHidden = false
                self.guardLabel.isHidden = false
                self.isRecord.accept(true)
            } else {
                self.finishRecording(success: true)
                self.setTimer()

                self.recordView.isHidden = true
                self.timeLabel.isHidden = true
                self.guardLabel.isHidden = true
                self.isRecord.accept(false)
            }
        }).disposed(by: rx.disposeBag)

        setButton(recordingBtn)
        setButton(fileBtn)
        setButton(coverBtn)

        setUpUI()
    }

    func setUpView() {

        lineView.layer.borderWidth = 1
        lineView.layer.borderColor = UIColor.gray.cgColor

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

    func loadRecordingUI() {
        recordingBtn.isSelected = true

        recordView.isHidden = false
        timeLabel.isHidden = false
        guardLabel.isHidden = false

        recordView.backgroundColor = .red
        recordView.layer.cornerRadius = 10
    }

    func setUpUI() {
        recordView.isHidden = true
        timeLabel.isHidden = true
        guardLabel.isHidden = true
        previewImg[0].isHidden = true
        previewDelete[0].isHidden = true
        previewImg[1].isHidden = true
        previewDelete[1].isHidden = true
    }

    func setTimer() {
        isRecord.asObservable().flatMapLatest {  isRecord in
            isRecord ? Observable<Int>.interval(1, scheduler: MainScheduler.instance) : .empty()
        }.subscribe(onNext: { value in
            if value == 300 {
                self.recording.stop()
                self.finishRecording(success: true)
                self.isRecord.accept(false)
            }
            self.timeLabel.text = String(value).formatTimer(value)
        }).disposed(by: rx.disposeBag)
    }

    func startRecording() {
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

    func finishRecording(success: Bool) {
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

    func getFileURL() -> URL {
        let fileName = NSUUID().uuidString + ".aac"
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func bindViewModel() {
        let input = PostViewModel.input(
            postText: postTextView.rx.text.orEmpty.asDriver(),
            selectFile: audioFile.asDriver(onErrorJustReturn: getFileURL()),
            selectCover: selectImg.asDriver(onErrorJustReturn: nil),
            doneTap: uploadBtn.rx.tap.asDriver())
        let output = viewModel.transform(input)

        output.isEnable.drive( self.uploadBtn.rx.isEnabled ).disposed(by: rx.disposeBag)
    }

    func setButton(_ button: UIButton) {
        button.layer.cornerRadius = 14
        button.backgroundColor = hexUIColor(hex: "efefef")
        button.tintColor = .darkGray
    }

    //지울거임
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

//Util에 extension으로
extension String {
    func getHashtags() -> [String]? {
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)

        let results = hashtagDetector?.matches(in: self, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: count))

        return results?.map({
            (self as NSString).substring(with: $0.range(at: 1)).capitalized
        })
    }

    func getPost(_ text: String) {
        let test = text.replacingOccurrences(of: "#", with: "")
        print(test)
    }

    func formatTimer(_ time: Int) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        return String(format:"%02i:%02i", minutes, seconds)
    }
}

extension PostViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioFile.accept(recorder.url)
        print(recorder.url)
    }
}

extension PostViewController: MPMediaPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        guard let mediaItem = mediaItemCollection.items.first else {
            NSLog("No item selected.")
            return
        }

        if let val = mediaItem.value(forKey: MPMediaItemPropertyAssetURL) as? URL {
            let asset = AVURLAsset.init(url: val)

            if asset.isExportable {
                let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)

                let exportPath: String = NSTemporaryDirectory().appendingFormat("/\(UUID().uuidString).m4a") as String
                let exportUrl: URL = NSURL.fileURL(withPath: exportPath as String) as URL

                exportSession?.outputURL = exportUrl as URL
                exportSession?.outputFileType = AVFileType.m4a
                audioFile.accept(exportUrl)

                exportSession?.exportAsynchronously(completionHandler: {
                    // do some stuff with the file
                    do {
                        try FileManager.default.removeItem(atPath: (exportPath as String?)!)
                        print(exportUrl)

                    } catch {
                        print(error)
                    }
                })
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectImg.accept(image.jpegData(compressionQuality: 0.2))
            previewImg[1].image = image
            previewImg[1].isHidden = false
            previewDelete[1].isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
}
