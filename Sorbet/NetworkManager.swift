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
    
}
