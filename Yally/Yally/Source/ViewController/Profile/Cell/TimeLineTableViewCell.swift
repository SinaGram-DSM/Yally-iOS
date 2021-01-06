//
//  TimeLineTableViewCell.swift
//  Yally
//
//  Created by 문지수 on 2021/01/03.
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
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var doYally: UIButton!
    @IBOutlet weak var doComment: UIButton!
    @IBOutlet weak var sliderBar: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewmoreBtn: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitle: UIButton!
    @IBOutlet weak var backImageBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!

    private var onPopup: Bool = false
    private var onClick: Bool = false
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        setUpUI()
        setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
      }

    func setUpUI() {
        backImageBtn.backgroundColor = .black
        backImageBtn.alpha = 0.7
        mainTextView.isEditable = false
        mainTextView.isSelectable = false
        mainTextView.textColor = .black
        userImageView.layer.cornerRadius = 20
        sliderBar.isHidden = true
        timeLabel.isHidden = true
        popupView.isHidden = true
        popupTitle.isHidden = true

        doYally.rx.tap.subscribe(onNext: { _ in
            self.doYally.isSelected = !self.doYally.isSelected
        }).disposed(by: rx.disposeBag)

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

        backImageBtn.rx.tap.subscribe(onNext: { _ in
            if self.backImageBtn.isSelected {
                self.backImageBtn.alpha = 0.3
                self.sliderBar.isHiddenAnimated(value: !self.backImageBtn.isSelected, duration: 0.5)
                self.timeLabel.isHiddenAnimated(value: !self.backImageBtn.isSelected, duration: 0.5)
            } else {
                self.backImageBtn.alpha = 0.7
                self.sliderBar.isHiddenAnimated(value: !self.backImageBtn.isSelected, duration: 0.5)
                self.timeLabel.isHiddenAnimated(value: !self.backImageBtn.isSelected, duration: 0.5)
            }
            self.backImageBtn.isSelected = !self.self.backImageBtn.isSelected
        }).disposed(by: rx.disposeBag)
    }

    func setupView() {
        popupView.layer.cornerRadius = 14
        popupView.layer.borderWidth = 0.5
        popupView.layer.borderColor = UIColor.gray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension UIView {
    func isHiddenAnimated(value: Bool, duration: Double = 0.3) {
        UIView.animate(withDuration: duration) { [weak self] in self?.isHidden = value }
    }
}
