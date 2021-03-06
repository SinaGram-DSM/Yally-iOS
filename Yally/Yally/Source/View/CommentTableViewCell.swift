//
//  CommentTableViewCell.swift
//  Yally
//
//  Created by 이가영 on 2020/11/01.
//

import UIKit
import RxSwift

final class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var deleteCommentBtn: UIButton!
    @IBOutlet weak var backCommentView: UIView!
    @IBOutlet weak var commentSoundView: UIView!

    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

       setupUI()
    }

    func setupUI() {
        backCommentView.backgroundColor = UIColor().hexUIColor(hex: "EFEFEF")
        backCommentView.layer.cornerRadius = 12

        commentSoundView.backgroundColor = UIColor().hexUIColor(hex: "FDFDFD")
        commentSoundView.layer.cornerRadius = 12

        commentTextView.sizeToFit()
        commentTextView.backgroundColor = .clear

        userImageView.layer.cornerRadius = 20

        postTimeLabel.textColor = .lightGray

        commentSlider.setThumbImage(UIImage(systemName: "circlebadge.fill"), for: .normal)

        playBtn.rx.tap.subscribe(onNext: {[unowned self] in
            playBtn.isSelected = !playBtn.isSelected
        }).disposed(by: rx.disposeBag)
    }

    func configCell(_ model: Comment) {
        commentSoundView.isHidden = model.sound == nil ? true : false
        deleteCommentBtn.isHidden = model.isMine ? false : true
        userImageView.load(urlString: model.user.img)
        userNameLabel.text = model.user.nickname
        commentTextView.text = model.content
        postTimeLabel.text = model.createdAt
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
