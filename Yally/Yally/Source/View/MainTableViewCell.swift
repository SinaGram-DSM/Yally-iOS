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
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        setupUI()
        setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func setupUI() {
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

        doYally.rx.tap.subscribe(onNext: {[unowned self] _ in
            doYally.isSelected = !doYally.isSelected
        }).disposed(by: rx.disposeBag)

        viewmoreBtn.rx.tap.subscribe(onNext: { [unowned self] _ in
            popupView.isHidden = onPopup ? true : false
            popupTitle.isHidden = onPopup ? true : false
            onPopup = !onPopup
        }).disposed(by: rx.disposeBag)

        backImageBtn.rx.tap.subscribe(onNext: {[unowned self] _ in
            backImageBtn.alpha = backImageBtn.isSelected ? 0.3 : 0.7
            sliderBar.isHiddenAnimated(value: !backImageBtn.isSelected, duration: 0.5)
            timeLabel.isHiddenAnimated(value: !backImageBtn.isSelected, duration: 0.5)
            backImageBtn.isSelected = !backImageBtn.isSelected
        }).disposed(by: rx.disposeBag)
    }

    func setupView() {
        popupView.layer.cornerRadius = 14
        popupView.layer.borderWidth = 0.5
        popupView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func configCell(_ model: MainModel) {
        userImageView.image = UIImage(named: model.user.img)
        userNameLabel.text = model.user.nickname
        postTimeLabel.text = model.createdAt
        mainTextView.text = model.content
        countOfYally.text = String(model.yally)
        countOfComment.text = String(model.comment)
        doYally.isSelected = model.isYally
        userImageView.load(urlString: model.user.img)
        backImageBtn.load(url: model.img!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

//extension에 합칠것
extension UIView {
    func isHiddenAnimated(value: Bool, duration: Double = 0.3) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.isHidden = value
        }
    }
}
