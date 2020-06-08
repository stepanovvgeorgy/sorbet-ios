//
//  Post.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 04.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import Foundation

enum PostType: Int {
    case Single = 0
    case Pun = 1
    case Collection = 2
}

struct Post {
    let id: Int?
    let type: PostType?
    let text: String?
    let userID: Int?
    let memes: Array<Meme>?
    let user: User?
}
