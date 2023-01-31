//
//  ViewController.swift
//  Log In
//
//  Created by Rustin Wilde on 22.01.23.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    private let label : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Log In"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
       
    }()
    
    private let emailAdressTField : UITextField = {
        let emailAdressTField = UITextField()
        emailAdressTField.placeholder = "Email Adress"
        emailAdressTField.layer.borderWidth = 1
        emailAdressTField.autocapitalizationType = .none
        emailAdressTField.layer.borderColor = UIColor.lightGray.cgColor
        emailAdressTField.leftViewMode = .always
        emailAdressTField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        emailAdressTField.layer.cornerRadius = 20
        return emailAdressTField
       
    }()
    
    private let passwordTField : UITextField = {
        let passwordTField = UITextField()
        passwordTField.placeholder = "Password"
        passwordTField.layer.borderWidth = 1
        passwordTField.isSecureTextEntry = true
        passwordTField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTField.leftViewMode = .always
        passwordTField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        passwordTField.layer.cornerRadius = 20
        return passwordTField
       
    }()
    
    private let button : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.layer.cornerRadius = 20
        return button
       
    }()
    
    private let signOutButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Log out", for: .normal)
        button.layer.cornerRadius = 20
        return button
       
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(emailAdressTField)
        view.addSubview(passwordTField)
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            label.isHidden = true
            emailAdressTField.isHidden = true
            passwordTField.isHidden = true
            button.isHidden = true
            
            view.addSubview(signOutButton)
            signOutButton.frame = CGRect(x: 20, y: 400, width: view.frame.size.width - 40, height: 52)
            signOutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
            signOutButton.isHidden = false
        }
    }
    
    @objc private func logoutTapped () {
        do{
            try FirebaseAuth.Auth.auth().signOut()
            label.isHidden = false
            emailAdressTField.isHidden = false
            passwordTField.isHidden = false
            button.isHidden = false
            
            signOutButton.removeFromSuperview()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        label.frame = CGRect(x: 0,
                             y: 100,
                             width: view.frame.size.width,
                             height: 80)
        
        emailAdressTField.frame = CGRect(
                             x: 20,
                             y: label.frame.origin.y + label.frame.size.height+10,
                             width: view.frame.size.width-40,
                             height: 50)
        
        passwordTField.frame = CGRect(x: 20,
                             y: emailAdressTField.frame.origin.y + label.frame.size.height+5,
                             width: view.frame.size.width-40,
                             height: 50)
        
        button.frame = CGRect(x: 20,
                             y: passwordTField.frame.origin.y + label.frame.size.height+5,
                             width: view.frame.size.width-40,
                             height: 52)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FirebaseAuth.Auth.auth().currentUser != nil {
            emailAdressTField.becomeFirstResponder()
        }
    }

    @objc private func didTapButton() {
        print("Logged In")
        guard let email = emailAdressTField.text, !email.isEmpty,
              let password = passwordTField.text, !password.isEmpty else {
            print("Missing field data")
            return
        }
        
        
        
        //Following steps:
        // 1 Get auth instance
        // 2 attempt sign in
        // 3 if failure, present alert to create account
        // 4 if user continues, create account
        
        // 5 check sign in on app launch
        // 6 allow user to sign out with button
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                //Account creation
                strongSelf.showCreateAccount(email: email, password: password)
                return
            }
            print("You've signed in")
            
            strongSelf.label.isHidden = true
            strongSelf.emailAdressTField.isHidden = true
            strongSelf.passwordTField.isHidden = true
            strongSelf.button.isHidden = true
            
            strongSelf.emailAdressTField.resignFirstResponder()
            strongSelf.passwordTField.resignFirstResponder()

        })
    }
    
    func showCreateAccount(email: String, password: String) {
        
        let alert = UIAlertController(title:  "Create Account",
                                      message: "Would you like to create an account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue",
                                      style: .default,
                                      handler: { _  in
                    FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
                        guard let strongSelf = self else {
                            return
                        }
                        guard error == nil else {
                            //Account creation
                            print("Account creation failed")
                            return
                        }
                        print("Account created")
                        print("You've signed in")
                        
                        strongSelf.label.isHidden = true
                        strongSelf.emailAdressTField.isHidden = true
                        strongSelf.passwordTField.isHidden = true
                        strongSelf.button.isHidden = true
                        
                        strongSelf.emailAdressTField.resignFirstResponder()
                        strongSelf.passwordTField.resignFirstResponder()
                    })
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { _  in
            
        }))
        
        present(alert, animated: true)
         
    }
    
}

