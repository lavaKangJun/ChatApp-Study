//
//  LoginController+handlers.swift
//  FirebaseChat
//
//  Created by 강준영 on 08/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func handleProfileimage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("cancel")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImage.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImage.image = originalImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleRegister() {
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error)
                return
            }
            guard let uid = result?.user.uid else {
                return
            }
            let imageUID = NSUUID().uuidString
            if let imageData = self.profileImage.image?.jpegData(compressionQuality: 0.1) {
                let storage = Storage.storage().reference().child("profileImages").child("\(imageUID).jpg")
                storage.putData(imageData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    storage.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        if let profileURL = url?.absoluteString {
                            let userValues = ["name": name, "email": email, "profileImage": profileURL]
                            self.registerUserFirebase(uid: uid, userValue: userValues as [String : AnyObject])
                        }
                    })
                })
            }
        }
    }
    
    func registerUserFirebase(uid: String, userValue: [String: AnyObject]) {
        // successfull
        let ref = Database.database().reference()
        let refChildPath = ref.child("users").child(uid)
        refChildPath.updateChildValues(userValue, withCompletionBlock: { [weak self] (error, reference) in
            if error != nil {
                print(error)
                return
            }
            let user = User()
            user.name = userValue["name"] as? String
            user.profileImage = userValue["profileImage"] as? String
            user.email = userValue["email"] as? String
            self?.messageController?.setupNaviTitleView(user: user)
            //Successfull
            self?.dismiss(animated: true, completion: nil)
        })
    }
}
