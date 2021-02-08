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

final class PostViewController: UIViewController {

    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var postTextView: UITextView!
    @IBOutlet weak private var lineView: UIView!
    @IBOutlet weak private var recordingBtn: UIButton!
    @IBOutlet weak private var fileBtn: UIButton!
    @IBOutlet weak private var coverBtn: UIButton!
    @IBOutlet private var previewImg: [UIImageView]!
    @IBOutlet private var previewDelete: [UIButton]!
    @IBOutlet weak private var uploadBtn: UIBarButtonItem!
    @IBOutlet weak private var recordView: UIImageView!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var guardLabel: UILabel!

    private var recordingSession: AVAudioSession!
    private var recording: AVAudioRecorder!
    private let hashtag: [String] = []
    private var isRecord = BehaviorRelay<Bool>(value: false)
    private let viewModel = PostViewModel()
    private var selectImg = BehaviorRelay<Data?>(value: nil)
    private var audioFile = PublishRelay<URL>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        defaultBtn(recordingBtn)
        defaultBtn(fileBtn)
        defaultBtn(coverBtn)

        setupUI()
        beforePost()

        postTextView.delegate = self
    }

    private func bindViewModel() {
        let input = PostViewModel.input(
            postText: postTextView.rx.text.orEmpty.asDriver(),
            selectFile: audioFile.asDriver(onErrorJustReturn: URL(string: "")!),
            selectCover: selectImg.asDriver(onErrorJustReturn: nil),
            doneTap: uploadBtn.rx.tap.asDriver())
        let output = viewModel.transform(input)

        output.result.emit(onCompleted: {[unowned self] in
            navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
    }

    private func beforePost() {
        fileBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            let alert = UIAlertController(title: "죄송해요", message: "준비 중이 서비스 입니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "네", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)

        coverBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
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

        recordingBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            recordView.isHidden = !isRecord.value
            guardLabel.isHidden = !isRecord.value
            timeLabel.isHidden = !isRecord.value
            isRecord.accept(!isRecord.value)
            !isRecord.value ? startRecording() : finishRecording(success: true)
            setTimer()
        }).disposed(by: rx.disposeBag)
    }

    private func setupUI() {
        recordView.isHidden = true
        timeLabel.isHidden = true
        guardLabel.isHidden = true
        previewImg[0].isHidden = true
        previewDelete[0].isHidden = true
        previewImg[1].isHidden = true
        previewDelete[1].isHidden = true
    }

    private func setTimer() {
        isRecord.asObservable().flatMapLatest {  isRecord in
            isRecord ? Observable<Int>.interval(1, scheduler: MainScheduler.instance) : .empty()
        }.subscribe(onNext: {[unowned self] value in
            if value == 300 {
                recording.stop()
                finishRecording(success: true)
                isRecord.accept(false)
            }
            timeLabel.text = String(value).formatTimer(value)
        }).disposed(by: rx.disposeBag)
    }

    private func startRecording() {
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

    func formatTimer(_ time: Int) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        return String(format:"%02i:%02i", minutes, seconds)
    }

    func convertHashtags(text: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        attrString.beginEditing()
        // match all hashtags
        do {
            // Find all the hashtags in our string
            let regex = try NSRegularExpression(pattern: "(?:\\s|^)(#(?:[a-zA-Z].*?|\\d+[a-zA-Z]+.*?))\\b", options: NSRegularExpression.Options.anchorsMatchLines)
            let results = regex.matches(
                in: text,
                options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                range: NSRange(location: 0, length: text.count))
            let array = results.map { (text as NSString).substring(with: $0.range) }
            for hashtag in array {
                let range = (attrString.string as NSString).range(of: hashtag)
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
            }
            attrString.endEditing()
        } catch {
            attrString.endEditing()
        }
        return attrString
    }
}

extension PostViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioFile.accept(recorder.url)
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

extension PostViewController: UITextViewDelegate {
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
