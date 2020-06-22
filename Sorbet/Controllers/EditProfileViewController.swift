//
//  EditProfileViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

fileprivate let textFieldCellReuseIdentifier = "TextFieldCell"
fileprivate let changeAvatarCellReuseIdentifier = "ChangeAvatarCell"

class EditProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var user: User?
    
    var userAvatarImage: UIImage?
    
    var firstNameTextField: UITextField?
    var lastNameTextField: UITextField?
    var aboutTextField: UITextField?
    var usernameTextField: UITextField?
    
    var imageFromPicker: UIImage? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func actionDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender: UIBarButtonItem) {
        updateUserProfile()
        dismiss(animated: true)
    }
    
    func updateUserProfile() {
        if let firstName = firstNameTextField?.text,
            let lastName = lastNameTextField?.text,
        !lastName.isEmpty && !firstName.isEmpty {
            let user = User(id: nil, token: nil, username: usernameTextField?.text, rating: nil, expiredDate: nil, avatar: nil, firstName: firstName, lastName: lastName, about: aboutTextField?.text, password: nil, email: nil)
            NetworkManager.shared.updateUserProfile(user: user) {
                self.sendNotificationUserProfileUpdated()
            }
        }
    }
    
    func sendNotificationUserProfileUpdated() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NotificationUserProfileUpdated"), object: nil)
    }
}

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellReuseIdentifier) as! TextFieldTableViewCell
        
        cell.textField.borderBottom(height: 1.5, color: #colorLiteral(red: 0.9791200757, green: 0.7600466609, blue: 0, alpha: 1))
        cell.textField.delegate = self
        
        if indexPath.row == 0 {
            firstNameTextField = cell.textField
            cell.textFieldLabel.text = "Имя"
            cell.textField.text = user?.firstName
        } else if indexPath.row == 1 {
            lastNameTextField = cell.textField
            cell.textFieldLabel.text = "Фамилия"
            cell.textField.text = user?.lastName
        } else if indexPath.row == 2 {
            aboutTextField = cell.textField
            cell.textFieldLabel.text = "О себе"
            cell.textField.text = user?.about
        } else if indexPath.row == 3 {
            usernameTextField = cell.textField
            cell.textFieldLabel.text = "Username"
            cell.textField.text = user?.username
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let changeAvatarCell = tableView.dequeueReusableCell(withIdentifier: changeAvatarCellReuseIdentifier) as! ChangeAvatarTableViewCell
            
            changeAvatarCell.avatarImageView.layer.cornerRadius = 80/2
            
            if userAvatarImage != nil {
                changeAvatarCell.avatarImageView.image = userAvatarImage
            }
            
            if imageFromPicker != nil {
                changeAvatarCell.avatarImageView.image = imageFromPicker
            }
            
            changeAvatarCell.changeAvatarButton.addTarget(self, action: #selector(presentImagePicker(_:)), for: .touchUpInside)
            
            return changeAvatarCell
        }
        
        return nil
    }
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func presentImagePicker(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        NetworkManager.shared.uploadImage(url: "/avatar/upload", image, resize: CGSize(width: 100, height: 100), compressionQuality: 0) {
            self.sendNotificationUserProfileUpdated()
            self.imageFromPicker = image
            picker.dismiss(animated: true, completion: nil)
        }

    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateUserProfile()
        textField.resignFirstResponder()
        return true
    }
}
