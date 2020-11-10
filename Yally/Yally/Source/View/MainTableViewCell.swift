//
//  MainTableViewCell.swift
//  Yally
//
//  Created by 이가영 on 2020/10/18.
//

import UIKit
import RxSwift
import NSObject_Rx

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var countOfYally: UILabel!
    @IBOutlet weak var countOfComment: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var doYally: UIButton!
    @IBOutlet weak var doComment: UIButton!
    @IBOutlet weak var sliderBar: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewmoreBtn: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitle: UIButton!

    private var onGesture: Bool = false
    private var onPopup: Bool = false

    override func awakeFromNib() {
        setUpUI()
        setupView()

        let tapGestureOn = UITapGestureRecognizer(target: self, action: #selector(touchToOn))
        backImageView?.addGestureRecognizer(tapGestureOn)
        backImageView?.isUserInteractionEnabled = true
    }

    func setUpUI() {
        backImageView.backgroundColor = .black
        backImageView.alpha = 0.7
        mainTextView.textAlignment = .center
        mainTextView.isEditable = false
        mainTextView.isSelectable = false
        mainTextView.textColor = .black
        mainTextView.sizeToFit()
        userImageView.layer.cornerRadius = 20
        sliderBar.isHidden = true
        timeLabel.isHidden = true
        popupView.isHidden = true
        popupTitle.isHidden = true

        viewmoreBtn.rx.tap.subscribe(onNext: { [unowned self] _ in
            if self.onPopup {
                self.popupView.isHidden = true
                self.popupTitle.isHidden = true

            } else {
                self.popupView.isHidden = false
                self.popupTitle.isHidden = false
            }
            self.onPopup = !self.onPopup
        }).disposed(by: rx.disposeBag)
    }

    func setupView() {
        popupView.layer.cornerRadius = 14
        popupView.layer.borderWidth = 0.5
        popupView.layer.borderColor = UIColor.gray.cgColor
    }

    @objc func touchToOn() {
        onGesture = !onGesture
        if !onGesture {
            //음원 재생

            backImageView.alpha = 0.3
            sliderBar.isHidden = false
            timeLabel.isHidden = false
        } else {
            //음원 재생

            backImageView.alpha = 0.7

            sliderBar.isHidden = true
            timeLabel.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
