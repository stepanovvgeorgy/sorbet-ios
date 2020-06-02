//
//  Helper.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class Helper {
    
    static var shared: Helper = {
        let instance = Helper()
        return instance
    }()
    
    func startApp(window: UIWindow?) {
        
        let token = UserDefaults.standard.value(forKey: "token")
        let user_id = UserDefaults.standard.value(forKey: "user_id")
        
        let isAuth = token != nil && user_id != nil
        
        if isAuth {
            let innerTabBarController = AppDelegate.storyboard.instantiateViewController(withIdentifier: "InnerTabBarController")
            window?.rootViewController = innerTabBarController
        }
    }
    
    func authFinished(fromViewController: UIViewController, userID: Int, token: String) {
        
        UserDefaults.standard.set(userID, forKey: "user_id")
        UserDefaults.standard.set(token, forKey: "token")
        
        let tabBarController = fromViewController.storyboard?.instantiateViewController(withIdentifier: "InnerTabBarController")
        tabBarController?.modalPresentationStyle = .fullScreen
        fromViewController.present(tabBarController!, animated: true)
    }
    
    func logout(_ completion: @escaping () -> ()) {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "user_id")
        completion()
    }
    
    func styledNavigationBar(navigationController: UINavigationController?, backgroundColor: UIColor?, textColor: UIColor?, isTranslucent: Bool?) {
        navigationController?.navigationBar.barTintColor = backgroundColor ?? UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: textColor ?? UIColor.white]
        navigationController?.navigationBar.isTranslucent = isTranslucent ?? true
    }
    
    func showInfoAlert(title: String?, message: String?) -> UIAlertController? {
        guard let title = title else {return nil}
        guard let message = message else {return nil}
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(closeButton)
        return alert
    }
    
    func navigationBarWithImage(vc: UIViewController?, imageNamed: String, width: Double, height: Double) {
        let image = UIImage(named: imageNamed)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        vc?.navigationItem.titleView = imageView
    }
    
    func customBarButtonWithImage(vc: UIViewController?, selector: Selector, image: UIImage) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        button.setImage(image, for: .normal)
        button.addTarget(vc, action: selector, for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        
        let width = barButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        width?.isActive = true
        
        let height = barButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        height?.isActive = true
        
        return barButton
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func activityAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Публикация...", message: "", preferredStyle: .alert)
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 40, width: alert.view.bounds.width, height: alert.view.bounds.height - 40))
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        alert.view.addSubview(activityIndicator)
        
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        return alert
    }
    
    func convertImageToBase64(_ image: UIImage) -> String {
        let imageData:NSData = image.jpegData(compressionQuality: 0.1)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
    func convertBase64ToImage(_ str: String) -> UIImage {
        let dataDecoded: Data = Data(base64Encoded: str, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage!
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    // https://stackoverflow.com/questions/32022906/how-can-i-convert-including-timezone-date-in-swift
    func convertTimestamp(dateString: String) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "dd MMMM yyyy 'в' H:m"
            let string = formatter.string(from: date)
            return string
        }
        
        return nil
    }

}
