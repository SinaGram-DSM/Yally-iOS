//
//  MainTableViewCell.swift
//  Yally
//
//  Created by 이가영 on 2020/10/18.
//

import UIKit

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
    
    private var onGesture: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sliderBar.isHidden = true
        timeLabel.isHidden = true
        
        setupTextView()
        
        let tapGestureOn = UITapGestureRecognizer(target: self, action: #selector(touchToOn))
        backImageView?.addGestureRecognizer(tapGestureOn)
        backImageView?.isUserInteractionEnabled = true
    }
    
    func setupTextView() {
        backImageView.backgroundColor = .black
        backImageView.alpha = 0.7
        backImageView.image = UIImage(named: "나은.jpeg")//
        
        mainTextView.textAlignment = .center
        mainTextView.isEditable = false
        mainTextView.isSelectable = false
        mainTextView.textColor = .black
        mainTextView.text = "슬라이더 등장이요슬라이더 등장이요슬라이더 등장이요슬라이더 등장이요슬"//
        
        let fixedWidth = mainTextView.frame.size.width
        let newSize = mainTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        mainTextView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
    
    @objc func touchToOn() {
        if !onGesture {
            //음원 재생
            
            backImageView.alpha = 0.3
            
            sliderBar.isHidden = false
            timeLabel.isHidden = false

            onGesture = true
            
        } else {
            //음원 재생
            
            backImageView.alpha = 0.7
            
            sliderBar.isHidden = true
            timeLabel.isHidden = true
           
            onGesture = false
        }
    }
    
    override var isSelected: Bool{
        didSet {
            doYally.tintColor = isSelected ? UIColor.purple
                : UIColor.gray
            doComment.tintColor = isSelected ? UIColor.purple
                : UIColor.gray
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
