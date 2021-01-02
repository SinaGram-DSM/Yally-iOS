//
//  ListenerTableViewCell.swift
//  Yally
//
//  Created by 문지수 on 2020/11/03.
//

import UIKit

import RxSwift
import RxCocoa

class ListenerTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var listeningBtn: UIButton!
//    @IBOutlet weak var valueLabel: UILabel!
//    @IBOutlet weak var middleLabel: UILabel!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var lastLabel: UILabel!

    var listenerData:ProfileModel! {
        didSet { setupView() }
    }
    
    private func setupView(){
        self.profileImage?.image = UIImage(named: listenerData.image)
        self.nickNameLabel?.text = listenerData.nickname

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
