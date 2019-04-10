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
        tv.font = UIFont.systemFont(ofSize: 20)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.widthAnchor.constraint(equalToConstant: 200),
            textView.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
