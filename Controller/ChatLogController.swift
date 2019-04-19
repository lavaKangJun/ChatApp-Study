//
//  ChatLogViewController.swift
//  FirebaseChat
//
//  Created by 강준영 on 08/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
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
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        imageView.image = UIImage(named: "picture")
        return imageView
    }()
    let cellId = "cellId"
    var messages = [Message]()
    var user: User? {
        didSet {
            self.navigationItem.title = user?.name
            observeMessage()
        }
    }
    var containerBottomAnchor: NSLayoutConstraint?
    lazy var inputCotainerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.white
        container.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        container.addSubview(seperator)
        NSLayoutConstraint.activate([
            seperator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            seperator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            seperator.topAnchor.constraint(equalTo: container.topAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 1)
            ])
        container.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            sendButton.widthAnchor.constraint(lessThanOrEqualToConstant: 50)
            ])
        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40)
            ])
        container.addSubview(chatTextField)
        NSLayoutConstraint.activate([
            chatTextField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            chatTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chatTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor)
            ])
        return container
    }()
    //inputAccessoryView는 inputView(일반적으로 키보드)위에 뜨는 보조적인 뷰
    override var inputAccessoryView: UIView? {
            return inputCotainerView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
        // Register cell classes
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupObserveKeyboard()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleTapGesture() {
        print("tap")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setupObserveKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIWindow.keyboardDidShowNotification, object: nil)
    }
  
    @objc func handleKeyboard() {
        if messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
            
        }
    }
    
    func observeMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-message").child(uid).child(user!.id!)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)
                if message.chatParterId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
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
        
        if let text = message.text {
            cell.messageViewWidthAnchor?.constant =
                estimatedMessageHeight(text: text).width + 30
        } else if let imageUrl = message.imageUrl {
            cell.messageViewWidthAnchor?.constant = 200
        }
        
        setupCell(cell: cell, message: message)
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.messageView.backgroundColor = UIColor(r: 0, g: 136, b: 249)
            cell.textView.textColor = UIColor.white
            cell.messageViewLeadingAnchor?.isActive = false
            cell.messageViewTrailingAnchor?.isActive = true
            cell.parterImage.isHidden = true
        } else {
            cell.messageView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            cell.textView.textColor = UIColor.black
            cell.messageViewLeadingAnchor?.isActive = true
            cell.messageViewTrailingAnchor?.isActive = false
            cell.parterImage.isHidden = false
            if let image = user?.profileImage {
                cell.parterImage.setProfileImage(strurl: image)
            }
        }
        
        if let imageUrl = message.imageUrl {
            cell.messageImage.backgroundColor = UIColor.clear
            cell.messageImage.setProfileImage(strurl: imageUrl)
            cell.messageImage.isHidden = false
        } else {
            cell.messageImage.isHidden = true
        }
           
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text = messages[indexPath.row].text {
            height = estimatedMessageHeight(text: text).height + 20
        } else if let imageHeight = messages[indexPath.row].imageHeight, let imageWidth = messages[indexPath.row].imageWidth {
            height = CGFloat(Float(imageHeight) / Float(imageWidth) * 200)
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var pickedImage: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            pickedImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            pickedImage = originalImage
        }
        guard let image = pickedImage, let data = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        let uid = NSUUID().uuidString
        let storage = Storage.storage().reference().child("message_image").child("\(uid).jpg")
        storage.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error)
            }
            storage.downloadURL(completion: { [weak self] (url, error) in
                if error != nil {
                    print(error)
                }
                if let url = url?.absoluteString {
                    self?.uploadMessageWith(imageUrl: url, image: image)
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func handleUpload(values: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        guard let fromId = Auth.auth().currentUser?.uid else {
            return
        }
        guard let toId = user?.id else {
            return
        }
        let timestampe = Int(NSDate().timeIntervalSince1970)
        var updateValue: [String: Any] = ["toId": toId, "fromId": fromId, "timestampe": timestampe]
        values.forEach {
            updateValue[$0] = $1
        }
        childRef.updateChildValues(updateValue) { (error, reference) in
            if error != nil {
                print(error)
            }
            self.chatTextField.text = nil
            let fromRef = Database.database().reference().child("user-message").child(fromId).child(toId)
            let toRef = Database.database().reference().child("user-message").child(toId).child(fromId)
            guard let messageId = reference.key else {
                return
            }
            fromRef.updateChildValues([messageId: 1])
            toRef.updateChildValues([messageId: 1])
        }
    }
    
    @objc func sendChat() {
        guard let text = chatTextField.text else {
            return
        }
        let value = ["text": text]
        handleUpload(values: value)
    }
    
    private func uploadMessageWith(imageUrl: String, image: UIImage) {
        let value = ["imageUrl": imageUrl, "imageHeight": image.size.height, "imageWidth": image.size.width] as [String : Any]
        handleUpload(values: value)
    }
    
    private func estimatedMessageHeight(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
}
