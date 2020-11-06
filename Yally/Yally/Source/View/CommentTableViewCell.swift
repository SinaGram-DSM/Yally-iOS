//
//  CommentTableViewCell.swift
//  Yally
//
//  Created by 이가영 on 2020/11/01.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
