//
//  Post.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 04.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import Foundation

struct Post {
    let id: Int?
    let type: Int?
    let text: String?
    let userID: Int?
    let memes: Array<Meme>?
}
