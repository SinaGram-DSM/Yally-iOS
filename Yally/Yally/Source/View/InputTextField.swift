//
//  InputTextField.swift
//  Yally
//
//  Created by 이가영 on 2020/11/14.
//

import UIKit

final class InputTextField: UIView {

    let commentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = UIColor().hexUIColor(hex: "EFEFEF")
        return textView
    }()

    let sendBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("입력", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    let recordBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "btn_rec.jpg"), for: .normal)

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        self.addSubview(commentTextView)
        self.addSubview(sendBtn)
        self.addSubview(recordBtn)

        commentTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        commentTextView.leadingAnchor.constraint(equalTo: recordBtn.trailingAnchor, constant: 6).isActive = true
        commentTextView.trailingAnchor.constraint(equalTo: sendBtn.leadingAnchor, constant: -6).isActive = true
        commentTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6).isActive = true
        commentTextView.widthAnchor.constraint(equalToConstant: 320).isActive = true

        sendBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        sendBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6).isActive = true
        sendBtn.leadingAnchor.constraint(equalTo: commentTextView.trailingAnchor, constant: 6).isActive = true
        sendBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6).isActive = true

        recordBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6).isActive = true
        recordBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        recordBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6).isActive = true
    }
}
