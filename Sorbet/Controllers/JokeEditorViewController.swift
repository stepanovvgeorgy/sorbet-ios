//
//  JokeEditorViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 19.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

fileprivate let jokeEditingLastTextUserDefaultsKey = "joke_editor_last_editing_text"

class JokeEditorViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var publishBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        textView.becomeFirstResponder()
        textView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        publishBarButtonItem.tintColor = .gray
        publishBarButtonItem.isEnabled = false
        
        let lastEditingText = UserDefaults.standard.value(forKey: jokeEditingLastTextUserDefaultsKey) as? String
        
        if lastEditingText != nil {
            publishBarButtonItem.isEnabled = true
            publishBarButtonItem.tintColor = UIColor.color.sunFlower
            textView.text = lastEditingText
        }
        
    }
    
    @IBAction func actionDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionPublish(_ sender: UIBarButtonItem) {
        sendPost()
    }
    
    func sendPost() {
        print("sendPost")
    }
}

extension JokeEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            publishBarButtonItem.isEnabled = true
            publishBarButtonItem.tintColor = UIColor.color.sunFlower
            UserDefaults.standard.set(textView.text, forKey: jokeEditingLastTextUserDefaultsKey)
        } else {
            publishBarButtonItem.isEnabled = false
            publishBarButtonItem.tintColor = .gray
            UserDefaults.standard.removeObject(forKey: jokeEditingLastTextUserDefaultsKey)
        }
    }
}
