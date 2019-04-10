//
//  ChatLogViewController.swift
//  FirebaseChat
//
//  Created by 강준영 on 08/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    
    let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(sendChat), for: .touchUpInside)
        return button
    }()
    lazy var chatTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let seperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return view
    }()
    let cellId = "cellId"
    var messages = [Message]()
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
            observeMessage()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.alwaysBounceVertical = true
        // Register cell classes
        self.collectionView!.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupComponents()
        
    }
    
    func observeMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                if self.user!.id == dictionary["toId"] as? String {
                    let message = Message()
                    message.fromId = dictionary["fromId"] as? String
                    message.toId = dictionary["toId"] as? String
                    message.text = dictionary["text"] as? String
                    message.timestampe = dictionary["timestampe"] as? Int
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }, withCancel: nil)
           
        }, withCancel: nil)
    }
    
    func setupComponents() {
        self.view.addSubview(container)
        container.backgroundColor = UIColor.white
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 60)
            ])
        self.view.addSubview(seperator)
        NSLayoutConstraint.activate([
            seperator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            seperator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            seperator.bottomAnchor.constraint(equalTo: container.topAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 1)
            ])
        container.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            sendButton.heightAnchor.constraint(equalTo: container.heightAnchor),
            sendButton.widthAnchor.constraint(lessThanOrEqualToConstant: 50),
            ])
        container.addSubview(chatTextField)
        NSLayoutConstraint.activate([
            chatTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            chatTextField.heightAnchor.constraint(equalTo: container.heightAnchor),
            chatTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor)
            ])
    }
    
    @objc func sendChat() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        guard let text = chatTextField.text else {
            return
        }
        guard let fromId = Auth.auth().currentUser?.uid else {
            return
        }
        guard let toId = user?.id else {
            return
        }
        let timestampe = Int(NSDate().timeIntervalSince1970)
        childRef.updateChildValues(["text": text, "toId": toId, "fromId": fromId, "timestampe": timestampe]) { (error, reference) in
            if error != nil {
                print(error)
            }
            let fromRef = Database.database().reference().child("user-message").child(fromId)
            let toRef = Database.database().reference().child("user-message").child(toId)
            guard let messageId = reference.key else {
                return
            }
            fromRef.updateChildValues([messageId: 1])
            toRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendChat()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            cellId, for: indexPath) as? ChatMessageCell else {
            return UICollectionViewCell()
        }
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}
