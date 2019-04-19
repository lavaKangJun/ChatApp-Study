//
//  ChatMessageCell.swift
//  FirebaseChat
//
//  Created by 강준영 on 10/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = " text message "
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.backgroundColor = nil
        tv.isEditable = false
        return tv
    }()
    let messageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 0, g: 136, b: 249)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    let parterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "world")
        imageView.isHidden = true
        return imageView
    }()
    let messageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var messageViewWidthAnchor: NSLayoutConstraint?
    var messageViewLeadingAnchor: NSLayoutConstraint?
    var messageViewTrailingAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(messageView)
        messageViewWidthAnchor = messageView.widthAnchor.constraint(equalToConstant: 200)
        messageViewLeadingAnchor = messageView.leadingAnchor.constraint(equalTo: self.parterImage.trailingAnchor, constant: 8)
        messageViewTrailingAnchor = messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            messageView.heightAnchor.constraint(equalTo: self.heightAnchor)
            ])
        messageViewTrailingAnchor?.isActive = true
        messageViewWidthAnchor?.isActive = true
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
            textView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: messageView.topAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor)
            ])
        
        addSubview(parterImage)
        NSLayoutConstraint.activate([
            parterImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            parterImage.bottomAnchor.constraint(equalTo: messageView.bottomAnchor),
            parterImage.heightAnchor.constraint(equalToConstant: 32),
            parterImage.widthAnchor.constraint(equalToConstant: 32)
            ])
        messageView.addSubview(messageImage)
        NSLayoutConstraint.activate([
            messageImage.topAnchor.constraint(equalTo: messageView.topAnchor),
            messageImage.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
            messageImage.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
            messageImage.heightAnchor.constraint(equalTo: messageView.heightAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
