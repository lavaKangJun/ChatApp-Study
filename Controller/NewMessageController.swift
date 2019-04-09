//
//  NewMessageController.swift
//  FirebaseChat
//
//  Created by 강준영 on 05/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellId = "cellId"
    var users = [User]()
    var messageController: MessageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserTableCell.self, forCellReuseIdentifier: cellId)
        fetchUsers()
    }
    
    func fetchUsers() {
        let ref = Database.database().reference().child("users")
        ref.observe(.childAdded, with: { [weak self] (snapShot) in
            if let dictionary = snapShot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapShot.key
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImage = dictionary["profileImage"] as? String
                self?.users.append(user)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserTableCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        if let profileUrl = users[indexPath.row].profileImage {
            cell.profileImage.setProfileImage(strurl: profileUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.messageController?.handleChat(user: self.users[indexPath.row])
            print("dismiss")
        }
    }
}

