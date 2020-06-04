//
//  NetworkManager.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let shared: NetworkManager = NetworkManager()
    
    let serverUrl = "http://192.168.1.5:4400/api"
    let uploadsUrl = "http://192.168.1.5:4400/uploads"
    let avatarsUrl = "http://192.168.1.5:4400/avatars"
    
    var headers: HTTPHeaders {
        get {
            let headersDict: [String: String] = ["Content-Type": "application/json"]
            let headers = HTTPHeaders(headersDict)
            return headers
        }
    }
    
    var headersWithToken: HTTPHeaders {
        get {
            let headersDict: [String: String] = [
                "Content-Type": "application/json",
                "token": UserDefaults.standard.value(forKey: "token") as! String
            ]
            
            let headers = HTTPHeaders(headersDict)
            
            return headers
        }
    }
    
    func signIn(user: User?, _ completion: @escaping (_ userID: Int, _ token: String) -> (), _ failure: @escaping (_ error: String) -> ()) {
        
        guard let url = URL(string: "\(serverUrl)/user/sign-in") else {return}
        
        if let user = user {
            let parameters: [String: String] = [
                "email": user.email!,
                "password": user.password!
            ]
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    
                    let jsonData = JSON(value)
                    
                    if response.response?.statusCode == 201 {
                        completion(jsonData["user_id"].intValue, jsonData["token"].stringValue)
                    } else {
                        failure(jsonData["message"].stringValue)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func signUp(user: User?, _ completion: @escaping (_ userID: Int, _ token: String) -> (), _ failure: @escaping (_ error: String) -> ()) {
        
        guard let url = URL(string: "\(serverUrl)/user/sign-up") else {return}
        
        if let user = user {
            let parameters: [String: Any] = [
                "avatar": user.avatar as Any,
                "email": user.email as Any,
                "password": user.password as Any,
                "first_name": user.firstName as Any,
                "last_name": user.lastName as Any
            ]
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    
                    let jsonData = JSON(value)
                    
                    if response.response?.statusCode == 201 {
                        completion(jsonData["user_id"].intValue, jsonData["token"].stringValue)
                    } else {
                        failure(jsonData["message"].stringValue)
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getUserByID(_ id: Int?, _ completion: @escaping (_ user: User?) -> (), _ failure: @escaping (_ error: String) -> ()) {
     
        if let userID = id {
            
            guard let url = URL(string: "\(serverUrl)/user/\(userID)") else {return}
            
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headersWithToken).validate().responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    
                    print(jsonData)
                    
                    if response.response?.statusCode == 200 {
      
                        let user = User(id: jsonData["id"].intValue,
                                        token: nil,
                                        username: jsonData["username"].stringValue,
                                        rating: jsonData["rating"].intValue,
                                        expiredDate: nil,
                                        avatar: "\(self.avatarsUrl)/\(jsonData["avatar"].stringValue)",
                                        firstName: jsonData["first_name"].stringValue,
                                        lastName: jsonData["last_name"].stringValue,
                                        about: jsonData["about"].stringValue,
                                        password: nil,
                                        email: nil)
                        
                        completion(user)
                        
                    } else {
                        failure(jsonData["message"].stringValue)
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
            
        }
    }
    
    func uploadImage(url: String, _ image: UIImage, resize: CGSize?, compressionQuality: CGFloat? = 0.9, _ completion: @escaping () -> ()) {
        
        let croppedImage = ImageHandler.shared.resizeImage(image: image, targetSize: resize ?? CGSize(width: 320, height: 240))
        
        guard let imageData = croppedImage.jpegData(compressionQuality: 0.9) else {return}
        
        AF.upload(multipartFormData: { (form) in
            form.append(imageData, withName: "file_data", fileName: "\(Helper.shared.randomString(length: 7)).jpg", mimeType: "image/jpeg")
            
            let token = UserDefaults.standard.value(forKey: "token") as! String
            
            form.append((token as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: "token")
            
        }, to: "\(serverUrl)\(url)", method: .post).response { result in
            completion()
        }
    }
    
    func updateUserProfile(user: User?, _ completion: @escaping () -> ()) {
        if user != nil {
            guard let url = URL(string: "\(serverUrl)/user/profile/update") else {return}
            
            let parameters: [String: Any] = [
                "username": user?.username as Any,
                "first_name": user?.firstName as Any,
                "last_name": user?.lastName as Any,
                "about": user?.about as Any
            ]
            
            AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headersWithToken).validate().responseJSON { (response) in
                  switch response.result {
                  case .success(let value):
                    
                      let jsonData = JSON(value)
                      
                      print(jsonData)

                      if response.response?.statusCode == 200 {
                        print("Data was update")
                        completion()
                      }
                      
                  case .failure(let error):
                      print(error.localizedDescription)
                  }
            }
        }
    }
    
    func getUserPostsByID(_ userID: Int, page: Int, limit: Int, _ completion: @escaping (_ posts: [Post], _ total: String) -> ()) {
        
        guard let url = URL(string: "\(NetworkManager.shared.serverUrl)/posts/\(userID)?page=\(page)&limit=\(limit)") else {
            return
        }
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headersWithToken).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                
                let jsonData = JSON(value)
                
                if response.response?.statusCode == 200 {
                    print(jsonData)
                } else {
                    print(jsonData)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
}
