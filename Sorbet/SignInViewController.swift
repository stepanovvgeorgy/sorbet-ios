//
//  ViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextFeild: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        emailTextField.borderBottom(height: 2)
        passwordTextFeild.borderBottom(height: 2)
    }
    
    @IBAction func actionSignIn(_ sender: Any) {
        
    }
    
    func signIn() {
        
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(emailTextField) {
            passwordTextFeild.becomeFirstResponder()
        } else {
            signIn()
        }
        
        return true
    }
}
