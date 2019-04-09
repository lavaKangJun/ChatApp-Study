//
//  LoginController.swift
//  FirebaseChat
//
//  Created by 강준영 on 02/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    let inputContainers: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Name"
        return textField
    }()
    let nameSeperator: UIView = {
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return seperator
    }()
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        return textField
    }()
    let emailSeperator: UIView = {
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return seperator
    }()
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        return textField
    }()
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "world")
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileimage)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    let loginSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Login", "Register"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 1
        segment.tintColor = .white
        segment.addTarget(self, action: #selector(handleSegment), for: .valueChanged)
        return segment
    }()
    var inputContainerHeight: NSLayoutConstraint?
    var nameTfHeight: NSLayoutConstraint?
    var nameSpHeight: NSLayoutConstraint?
    var emailTfHeight: NSLayoutConstraint?
    var passwordTfHeight: NSLayoutConstraint?
    var messageController: MessageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(r: 6, g: 91, b: 151)
        setupInputContainers()
        setupRegisterButton()
        setupLoginSegment()
        setupProfileImage()
    }
    
    func setupLoginSegment() {
        view.addSubview(loginSegment)
        NSLayoutConstraint.activate([
            loginSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginSegment.bottomAnchor.constraint(equalTo: inputContainers.topAnchor, constant: -10),
            loginSegment.widthAnchor.constraint(equalTo: inputContainers.widthAnchor),
            loginSegment.heightAnchor.constraint(equalToConstant: 30)
            ])
    }
    
    func setupInputContainers() {
        view.addSubview(inputContainers)
        inputContainerHeight = inputContainers.heightAnchor.constraint(equalToConstant: 150)
        NSLayoutConstraint.activate([
            inputContainers.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -24),
            inputContainers.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputContainers.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        inputContainerHeight?.isActive = true
        
        inputContainers.addSubview(nameTextField)
        nameTfHeight = nameTextField.heightAnchor.constraint(equalTo: inputContainers.heightAnchor, multiplier: 1/3)
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: inputContainers.leadingAnchor, constant: 12),
            nameTextField.widthAnchor.constraint(equalTo: inputContainers.widthAnchor,  multiplier: 1, constant: -12),
            nameTextField.topAnchor.constraint(equalTo: inputContainers.topAnchor)
            ])
        nameTfHeight?.isActive = true
        
        inputContainers.addSubview(nameSeperator)
        nameSpHeight = nameSeperator.heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate([
            nameSeperator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeperator.widthAnchor.constraint(equalTo: inputContainers.widthAnchor),
            ])
        nameSpHeight?.isActive = true
        
        inputContainers.addSubview(emailTextField)
        emailTfHeight = emailTextField.heightAnchor.constraint(equalTo: inputContainers.heightAnchor, multiplier: 1/3)
        NSLayoutConstraint.activate([
            emailTextField.leadingAnchor.constraint(equalTo: inputContainers.leadingAnchor, constant: 12),
            emailTextField.widthAnchor.constraint(equalTo: inputContainers.widthAnchor,  multiplier: 1, constant: -12),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor)
            ])
        emailTfHeight?.isActive = true
        
        inputContainers.addSubview(emailSeperator)
        NSLayoutConstraint.activate([
            emailSeperator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeperator.widthAnchor.constraint(equalTo: inputContainers.widthAnchor),
            emailSeperator.heightAnchor.constraint(equalToConstant: 1)
            ])
        
        inputContainers.addSubview(passwordTextField)
        passwordTfHeight =
            passwordTextField.heightAnchor.constraint(equalTo: inputContainers.heightAnchor, multiplier: 1/3)
        NSLayoutConstraint.activate([
            passwordTextField.leadingAnchor.constraint(equalTo: inputContainers.leadingAnchor, constant: 12),
            passwordTextField.widthAnchor.constraint(equalTo: inputContainers.widthAnchor,  multiplier: 1, constant: -12),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor)
            ])
        passwordTfHeight?.isActive = true
    }
    
    func setupRegisterButton() {
        view.addSubview(registerButton)
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: inputContainers.bottomAnchor, constant: 10),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.widthAnchor.constraint(equalTo: inputContainers.widthAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    func setupProfileImage() {
        view.addSubview(profileImage)
        NSLayoutConstraint.activate([
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImage.bottomAnchor.constraint(equalTo: loginSegment.topAnchor, constant: -30),
            profileImage.widthAnchor.constraint(equalToConstant: 150),
            profileImage.heightAnchor.constraint(equalToConstant: 150)
            ])
    }
    
    @objc func handleLoginRegister() {
        if loginSegment.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if error != nil {
                print(error)
                return
            }
            
            self?.messageController?.fetchUserAndSetupNaviTitle()
            //Successfull
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func handleSegment() {
        let title = loginSegment.titleForSegment(at: loginSegment.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        // Change Input Height
        inputContainerHeight?.isActive = false
        inputContainerHeight = inputContainers.heightAnchor.constraint(equalToConstant: loginSegment.selectedSegmentIndex == 0 ? 100: 150)
        inputContainerHeight?.isActive = true
        // Chage NameTextField
        nameTfHeight?.isActive = false
        nameTfHeight = nameTextField.heightAnchor.constraint(equalTo: inputContainers.heightAnchor, multiplier: loginSegment.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTfHeight?.isActive = true
        // Change NameSeperator
        nameSpHeight?.isActive = false
        nameSpHeight = nameSeperator.heightAnchor.constraint(equalToConstant: loginSegment.selectedSegmentIndex == 0 ? 0 : 1)
        nameSpHeight?.isActive = true
        // Change EmailTextField
        emailTfHeight?.isActive = false
        emailTfHeight = emailTextField.heightAnchor.constraint(equalTo: inputContainers.heightAnchor, multiplier: loginSegment.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTfHeight?.isActive = true
        // Change PasswordTextField
        passwordTfHeight?.isActive = false
        passwordTfHeight = passwordTextField.heightAnchor.constraint(equalTo: inputContainers.heightAnchor, multiplier: loginSegment.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTfHeight?.isActive = true
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}
