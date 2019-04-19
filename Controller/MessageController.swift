//
//  ViewController.swift
//  FirebaseChat
//
//  Created by 강준영 on 02/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    var messages = [Message]()
    var dicMessages = [String: Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        checkUserLogin()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserTableCell.self, forCellReuseIdentifier: "cellId")
    }
    
    func observeUserChat() {
        guard let user = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-message").child(user)
        ref.observe(.childAdded, with: { (snapshot) in
            let parterId = snapshot.key
            Database.database().reference().child("user-message").child(user).child(parterId).observe(.childAdded, with: { (sanpshot) in
                print(sanpshot)
                let messageId = sanpshot.key
                self.fetchMessage(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    @objc func handleReloadData() {
        DispatchQueue.main.async {
            print("ReloadData")
            self.tableView.reloadData()
        }
    }
    
    private func fetchMessage(messageId: String) {
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.observe(.value, with: { (msgSnapshot) in
            guard let dictionary = msgSnapshot.value as? [String: AnyObject] else {
                return
            }
            
            let message = Message(dictionary: dictionary)
            if let chatParterId = message.chatParterId() {
                self.dicMessages[chatParterId] = message
                self.messages = Array(self.dicMessages.values)
                self.messages.sort(by: { (message1, message2) -> Bool in
                    return message1.timestampe! > message2.timestampe!
                })
            }
            
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadData), userInfo: nil, repeats: false)
            
        }, withCancel: nil)
    }
    
    func checkUserLogin() {
        if Auth.auth().currentUser?.uid == nil {
            performSelector(onMainThread: #selector(handleLogout), with: nil, waitUntilDone: false)
        } else {
           self.fetchUserAndSetupNaviTitle()
        }
    }
    
    func fetchUserAndSetupNaviTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapShot) in
            if let dictionary = snapShot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImage = dictionary["profileImage"] as? String
                self.setupNaviTitleView(user: user)
            }
        }, withCancel: nil)
    }
    
    func setupNaviTitleView(user: User) {
        messages.removeAll()
        dicMessages.removeAll()
        tableView.reloadData()
        observeUserChat()
        let titleView = UIView()
        titleView.backgroundColor = UIColor.red
        self.navigationItem.titleView = titleView
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
            ])
        
        let profileImage = UIImageView()
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 20
        profileImage.layer.masksToBounds = true
        container.addSubview(profileImage)
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            profileImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            profileImage.heightAnchor.constraint(equalToConstant: 40),
            profileImage.widthAnchor.constraint(equalToConstant: 40)
            ])
        if let image = user.profileImage {
            profileImage.setProfileImage(strurl: image)
        }
        
        let nameLabel = UILabel()
        container.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            nameLabel.heightAnchor.constraint(equalTo: profileImage.heightAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
        nameLabel.text = user.name
    }
    
    func handleChat(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleNewMessage() {
        let newMessage = NewMessageController()
        newMessage.messageController = self
        let navigation = UINavigationController(rootViewController: newMessage)
        self.present(navigation, animated: true, completion: nil)
    }
    
    @objc func handleLogout() {
        do {
            try? Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        let loginViewController = LoginController()
        loginViewController.messageController = self
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? UserTableCell else {
            return UITableViewCell()
        }
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let parterId = messages[indexPath.row].chatParterId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(parterId)
        ref.observeSingleEvent(of: .value, with: { [weak self] (sanpshot) in
            guard let dictionary = sanpshot.value as? [String: AnyObject] else {
                return
            }
            let user = User()
            user.id = parterId
            user.email = dictionary["email"] as? String
            user.name = dictionary["name"] as? String
            user.profileImage = dictionary["profileImage"] as? String
            self?.handleChat(user: user)
        }, withCancel: nil)
    }
}

