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
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var guardLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    var recording: AVAudioRecorder!
    var isRecord: Bool = false
    let hashtag: [String] = []
    
    private let viewModel = PostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recordView.isHidden = true
        timeLabel.isHidden = true
        guardLabel.isHidden = true
        
        setButton(recordingBtn)
        setButton(fileBtn)
        setButton(coverBtn)
        
        setUpUI()
    }
    
    func setUpView() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try? recordingSession.setCategory(.record, mode: .default)
            try? recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [weak self] allowed in
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
        
        coverBtn.rx.tap.asObservable().subscribe(onNext: {
        }).disposed(by: rx.disposeBag)

        recordingBtn.rx.tap.asObservable().subscribe(onNext: {
            if self.isRecord {
                self.recording?.record()
            } else {
                self.recording?.stop()
            }
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
            recording?.record()
            recordingBtn.isSelected = true
        } catch {
            recording?.stop()
        }
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return path as URL
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func bindViewModel() {
        
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
}

extension PostViewController: AVAudioRecorderDelegate {
    
}
