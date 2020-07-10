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

fileprivate let networkProtocol = "http"
fileprivate let networkHost = "localhost"
fileprivate let networkPort = "4400"

class NetworkManager {
    
    static let shared: NetworkManager = NetworkManager()
    
    let serverUrl = "\(networkProtocol)://\(networkHost):\(networkPort)/api"
    let uploadsUrl = "\(networkProtocol)://\(networkHost):\(networkPort)/uploads"
    let avatarsUrl = "\(networkProtocol)://\(networkHost):\(networkPort)/avatars"
    
    var headers: HTTPHeaders {
        get {
            let headersDict: [String: String] = ["Content-Type": "application/json"]
            let headers = HTTPHeaders(headersDict)
            return headers
        }
    }
    
    var headersWithToken: HTTPHeaders {
        get {
            let headersDictionary: [String: String] = [
                "Content-Type": "application/json",
                "token": UserDefaults.standard.value(forKey: "token") as! String
            ]
            
            let headers = HTTPHeaders(headersDictionary)
            
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
                "email": user.email as Any,
                "username": user.username as Any,
                "password": user.password as Any
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
    
    func uploadImage(url: String, _ image: UIImage, resize: CGSize?, compressionQuality: CGFloat? = 0.9, _ completion: @escaping (_ meme: Meme?) -> ()) {
        
        let croppedImage = ImageHandler.shared.resizeImage(image: image, targetSize: resize ?? CGSize(width: 320, height: 240))
        
        guard let imageData = croppedImage.jpegData(compressionQuality: 0.9) else {return}
        
        AF.upload(multipartFormData: { (form) in
            form.append(imageData, withName: "file_data", fileName: "\(Helper.shared.randomString(length: 7)).jpg", mimeType: "image/jpeg")
            
            let token = UserDefaults.standard.value(forKey: "token") as! String
            
            form.append((token as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: "token")
            
        }, to: "\(serverUrl)\(url)", method: .post).response { result in
            
            let jsonData = JSON(result.data as Any)
            
            print(jsonData)
            
            let memeImageURL = "\(self.uploadsUrl)/\(jsonData["image_name"].stringValue)"
            
            let meme = Meme(id: jsonData["id"].intValue, imageName: memeImageURL, userID: jsonData["UserId"].intValue, user: nil)
            
            completion(meme)
        }
    }
    
    func getMemesByUserID(_ id: Int?, page: Int, limit: Int, _ completion: @escaping (_ memes: [Meme], _ total: Int) -> ()) {
        if let userID = id {
            
            guard let url = URL(string: "\(serverUrl)/meme/user/\(userID)?page=\(page)&limit=\(limit)") else {return}
            
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headersWithToken).validate().responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    if response.response?.statusCode == 200 {
                        
                        let jsonData = JSON(value)
                        
                        let total = Int((response.response?.headers["total"])!)
                        
                        var memesArray: [Meme] = Array()
                        
                        jsonData.array!.forEach({ (item) in
                            
                            let user = User(id: item["UserId"].intValue,
                                            token: nil,
                                            username: item["User"]["username"].stringValue,
                                            rating: item["User"]["rating"].intValue,
                                            expiredDate: nil,
                                            avatar: "\(self.avatarsUrl)/\(item["User"]["avatar"].stringValue)",
                                firstName: item["User"]["first_name"].stringValue,
                                lastName: item["User"]["last_name"].stringValue,
                                about: nil,
                                password: nil,
                                email: nil)
                            
                            let meme = Meme(id: item["id"].intValue,
                                            imageName: "\(self.uploadsUrl)/\(item["image_name"].stringValue)",
                                userID: item["UserId"].intValue, user: user)
                            memesArray.append(meme)
                        })
                        
                        completion(memesArray, total!)
                        
                    } else {
                        print("Something went wrong")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getAllMemes(page: Int, limit: Int, _ completion: @escaping (_ memes: [Meme], _ total: Int) -> ()) {
        
        guard let url = URL(string: "\(serverUrl)/meme/all?page=\(page)&limit=\(limit)") else {return}
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headersWithToken).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                if response.response?.statusCode == 200 {
                    
                    let jsonData = JSON(value)
                    
                    let total = Int((response.response?.headers["total"])!)
                    
                    var memesArray: [Meme] = Array()
                    
                    jsonData.array!.forEach({ (item) in
                        
                        let user = User(id: item["UserId"].intValue,
                                        token: nil,
                                        username: item["User"]["username"].stringValue,
                                        rating: item["User"]["rating"].intValue,
                                        expiredDate: nil,
                                        avatar: "\(self.avatarsUrl)/\(item["User"]["avatar"].stringValue)",
                            firstName: item["User"]["first_name"].stringValue,
                            lastName: item["User"]["last_name"].stringValue,
                            about: nil,
                            password: nil,
                            email: nil)
                        
                        let meme = Meme(id: item["id"].intValue,
                                        imageName: "\(self.uploadsUrl)/\(item["image_name"].stringValue)",
                            userID: item["UserId"].intValue,
                            user: user)
                        memesArray.append(meme)
                    })
                    
                    completion(memesArray, total!)
                    
                } else {
                    print(value as Any)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func searchUserByUsername(_ username: String?, _ completion: @escaping ([User]) -> (), _ failure: @escaping () -> ()) {
        
        if username != nil {
            
            guard let url = URL(string: "\(serverUrl)/user/search") else {return}
            
            let parameters: [String: String] = [
                "username": username!
            ]
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headersWithToken).validate().responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    if response.response?.statusCode == 200 {
                        
                        var users: [User] = []
                        
                        let jsonData = JSON(value)
                        
                        jsonData.array!.forEach { (item) in
                            let user = User(id: item["id"].intValue,
                                            token: nil,
                                            username: item["username"].stringValue,
                                            rating: nil, expiredDate: nil,
                                            avatar: "\(self.avatarsUrl)/\(item["avatar"].stringValue)",
                                firstName: nil,
                                lastName: nil,
                                about: nil,
                                password: nil,
                                email: nil)
                            users.append(user)
                        }
                        
                        completion(users)
                        
                    }
                    
                case .failure(let error):
                    failure()
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getSubscriptionsByUserID(_ id: Int?, page: Int = 1, limit: Int = 15, completion: @escaping (_ users: [User], _ total: Int?) -> (), failure: @escaping (_ error: Any?) -> ()) {
        if let userID = id {
            
            guard let url = URL(string: "\(serverUrl)/subscriptions/\(userID)?page=\(page)&limit=\(limit)") else {return}
            
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headersWithToken).validate().responseJSON { (response) in
                switch response.result {
                case .success(let data):
                    
                    let jsonData = JSON(data)
                    
                    if response.response?.statusCode == 200 {
                        
                        var users = [User]()
                        
                        jsonData.array!.forEach { (item) in
                            let user = User(id: item["id"].intValue,
                                            token: nil,
                                            username: item["username"].stringValue,
                                            rating: nil,
                                            expiredDate: nil,
                                            avatar: "\(self.avatarsUrl)/\(item["avatar"].stringValue)",
                                            firstName: nil,
                                            lastName: nil,
                                            about: nil,
                                            password: nil,
                                            email: nil)
                            users.append(user)
                        }
                        
                        let total = Int((response.response?.headers["total"])!)
                        
                        completion(users, total)
                        
                    } else {
                        print(jsonData)
                        failure(jsonData)
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    failure(error.localizedDescription)
                }
            }
        }
    }
}
