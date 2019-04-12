//
//  UserCell.swift
//  FirebaseChat
//
//  Created by 강준영 on 09/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase

class UserTableCell: UITableViewCell {
    var message: Message? {
        didSet {
            setUpChatter()
        }
    }
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 76, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 76, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImage)
        NSLayoutConstraint.activate([
            profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            profileImage.widthAnchor.constraint(equalToConstant: 60),
            profileImage.heightAnchor.constraint(equalToConstant: 60)
            ])
        addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
    }
    private func setUpChatter() {
        if let id = message?.chatParterId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    guard let imageUrl = dictionary["profileImage"] as? String else {
                        return
                    }
                    self.profileImage.setProfileImage(strurl: imageUrl)
                }
            }, withCancel: nil)
        }
        self.detailTextLabel?.text = message?.text
        if let stamp = message?.timestampe{
            let time = NSDate(timeIntervalSince1970: Double(stamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            self.timeLabel.text = dateFormatter.string(from: time as Date)
        }
    }
}
