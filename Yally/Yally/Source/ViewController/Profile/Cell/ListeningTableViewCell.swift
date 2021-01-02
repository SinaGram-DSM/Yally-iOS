//
//  ListeningTableViewCell.swift
//  Yally
//
//  Created by 문지수 on 2020/10/27.
//

import UIKit

import RxSwift
import RxCocoa

class ListeningTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLbl: UILabel!
    @IBOutlet weak var unListeningBtn: UIButton!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    
    var listeningData:ProfileModel! {
        didSet { setupView() }
    }
    
    private func setupView(){
        //self.roomName?.text = roomData.room
        self.nickNameLbl?.text = listeningData.nickname
        self.profileImage?.image = UIImage(named: listeningData.image)
        
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
