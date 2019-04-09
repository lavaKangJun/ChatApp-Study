//
//  ChatLogViewController.swift
//  FirebaseChat
//
//  Created by 강준영 on 08/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
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
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = UIColor.white

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        setupComponents()
    }
    
    func setupComponents() {
        self.view.addSubview(container)
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
        childRef.updateChildValues(["text": text, "toId": toId, "fromId": fromId, "timestampe": timestampe])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendChat()
        return true
    }
}
